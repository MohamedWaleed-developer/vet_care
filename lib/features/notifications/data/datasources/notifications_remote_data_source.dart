import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../../core/services/firebase/firestore_service.dart';

import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService;

  NotificationsRemoteDataSource(
      this._firestoreService,
      this._authService,
      );

  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _authService.currentUserId;

    if (userId == null || userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirebaseCollections.notifications)
        .where(
      'userId',
      isEqualTo: userId,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(NotificationModel.fromFirestore)
            .toList();
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.updateDocument(
      path:
      '${FirebaseCollections.notifications}/$notificationId',
      data: {
        'isRead': true,
      },
    );
  }

  Future<void> markAllAsRead() async {
    final userId = _authService.currentUserId;

    if (userId == null || userId.isEmpty) {
      return;
    }

    final snapshot = await _firestoreService
        .collection(FirebaseCollections.notifications)
        .where(
      'userId',
      isEqualTo: userId,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    await _firestoreService.updateDocuments(
      updates: {
        for (final document in snapshot.docs)
          '${FirebaseCollections.notifications}/${document.id}': {
            'isRead': true,
          },
      },
    );
  }
}
