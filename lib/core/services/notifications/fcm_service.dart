import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../features/orders/data/repositories/orders_repository.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firestore_service.dart';
import '../../routing/app_navigator.dart';
import '../../routing/route_names.dart';
import 'notification_service.dart';

class FcmService implements NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final OrdersRepository _ordersRepository;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  String? _savedDevicePath;
  bool _initialized = false;

  FcmService(
    this._messaging,
    this._authService,
    this._firestoreService,
    this._ordersRepository,
  );

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await requestPermission();
    await _messaging.setAutoInitEnabled(true);

    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => unawaited(_handleNotificationTap(message)),
    );

    _tokenSubscription = onTokenRefresh.listen((_) {
      unawaited(_saveDeviceTokenSafely());
    });

    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user == null) {
        unawaited(_deactivateSavedDevice());
      } else {
        unawaited(_saveDeviceTokenSafely());
      }
    });

    await _saveDeviceTokenSafely();

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_handleNotificationTap(initialMessage));
      });
    }
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<void> saveDeviceToken() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final token = await getToken();
    if (token == null || token.isEmpty) return;

    final deviceId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
    final devicePath = 'users/$userId/devices/$deviceId';

    if (_savedDevicePath != null && _savedDevicePath != devicePath) {
      await _deactivateSavedDevice();
    }

    final document = await _firestoreService.getDocument(devicePath);

    final data = <String, dynamic>{
      'token': token,
      'deviceId': deviceId,
      'platform': _platformName,
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!document.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await _firestoreService.setDocument(
      path: devicePath,
      data: data,
      merge: true,
    );

    _savedDevicePath = devicePath;
    debugPrint('FCM device token saved successfully.');
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  String get _platformName {
    if (kIsWeb) return 'web';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  Future<void> _saveDeviceTokenSafely() async {
    try {
      await saveDeviceToken();
    } catch (error, stackTrace) {
      debugPrint('FCM token save failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _deactivateSavedDevice() async {
    final path = _savedDevicePath;
    if (path == null) return;

    try {
      await _firestoreService.updateDocument(
        path: path,
        data: {'isActive': false, 'updatedAt': FieldValue.serverTimestamp()},
      );
    } catch (error) {
      debugPrint('FCM device deactivation failed: $error');
    } finally {
      _savedDevicePath = null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM message received while app is open.');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    final type = _stringValue(
      data['type'] ?? data['notificationType'],
    ).toLowerCase();

    final navigator = AppNavigator.key.currentState;

    if (navigator == null) {
      debugPrint('Notification navigation skipped: navigator not ready.');
      return;
    }

    if (_isOrderNotification(type)) {
      final orderId = _stringValue(data['orderId'] ?? data['relatedId']);

      if (orderId.isEmpty) {
        debugPrint('Order notification has no orderId.');
        return;
      }

      try {
        final order = await _ordersRepository.getOrder(orderId);
        if (order == null) {
          debugPrint('Order unavailable or does not belong to this user.');
          return;
        }

        final currentNavigator = AppNavigator.key.currentState;
        if (currentNavigator == null) return;

        currentNavigator.pushNamed(RouteNames.orderDetails, arguments: order);
      } catch (error, stackTrace) {
        debugPrint('Unable to open order from notification: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      return;
    }

    if (_isVaccinationNotification(type)) {
      final petId = _stringValue(data['petId'] ?? data['relatedId']);

      if (petId.isEmpty) {
        debugPrint('Vaccination notification has no petId.');
        return;
      }

      navigator.pushNamed(RouteNames.vaccinations, arguments: petId);
      return;
    }

    debugPrint('No destination configured for notification type: $type');
  }

  bool _isOrderNotification(String type) {
    return type == 'order' ||
        type.startsWith('order_') ||
        type == 'new_order' ||
        type == 'order_update';
  }

  bool _isVaccinationNotification(String type) {
    return type == 'vaccination' ||
        type == 'vaccine' ||
        type == 'vaccination_reminder' ||
        type == 'pet_vaccination';
  }

  String _stringValue(dynamic value) {
    return value is String ? value.trim() : '';
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _authSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
