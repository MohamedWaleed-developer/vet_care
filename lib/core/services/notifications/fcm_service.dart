import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

class FcmService implements NotificationService {
  final FirebaseMessaging _messaging;

  FcmService(this._messaging);

  @override
  Future<void> initialize() async {
    await requestPermission();

    await _messaging.setAutoInitEnabled(true);

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );
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
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  @override
  Future<void> saveDeviceToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return;
    }
  }

  @override
  Stream<String> get onTokenRefresh {
    return _messaging.onTokenRefresh;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM MESSAGE RECEIVED');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM NOTIFICATION TAPPED');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }
}