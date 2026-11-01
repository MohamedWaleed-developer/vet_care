import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.relatedId,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final timestamp = data['createdAt'];

    return NotificationModel(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      relatedId: data['relatedId'] as String?,
      data: Map<String, dynamic>.from(
        data['data'] as Map? ?? {},
      ),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}