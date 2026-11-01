import 'package:flutter/material.dart';

import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _NotificationStyle.fromType(
      notification.type,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(
              icon: style.icon,
              iconColor: style.iconColor,
              backgroundColor: style.backgroundColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NotificationContent(
                notification: notification,
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  top: 6,
                  right: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _NotificationIcon({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationContent({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatTime(notification.createdAt),
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'منذ لحظات';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    }

    if (difference.inDays == 1) {
      return 'أمس';
    }

    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _NotificationStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  factory _NotificationStyle.fromType(String type) {
    switch (type) {
      case 'order':
        return const _NotificationStyle(
          icon: Icons.local_shipping_outlined,
          iconColor: Color(0xFF2E8B57),
          backgroundColor: Color(0xFFE8F5E9),
        );

      case 'vaccination':
        return const _NotificationStyle(
          icon: Icons.calendar_today_outlined,
          iconColor: Color(0xFFE67E22),
          backgroundColor: Color(0xFFFFF3E0),
        );

      case 'offer':
        return const _NotificationStyle(
          icon: Icons.link_rounded,
          iconColor: Color(0xFF10B981),
          backgroundColor: Color(0xFFD1FAE5),
        );

      case 'payment':
        return const _NotificationStyle(
          icon: Icons.verified_user_outlined,
          iconColor: Color(0xFF3B9B7E),
          backgroundColor: Color(0xFFE0F2F1),
        );

      case 'product':
      case 'service':
        return const _NotificationStyle(
          icon: Icons.inventory_2_outlined,
          iconColor: Color(0xFF3B9B7E),
          backgroundColor: Color(0xFFE0F2F1),
        );

      default:
        return const _NotificationStyle(
          icon: Icons.notifications_none_outlined,
          iconColor: Color(0xFF3B9B7E),
          backgroundColor: Color(0xFFE0F2F1),
        );
    }
  }
}