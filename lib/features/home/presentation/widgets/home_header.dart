import 'package:flutter/material.dart';

import '../home_colors.dart';

/// الهيدر: الصورة + الترحيب + جرس الإشعارات
class HomeHeader extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final int notificationsCount;
  final VoidCallback? onNotificationsTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.photoUrl,
    this.notificationsCount = 0,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // الصورة (على اليمين في RTL)
        CircleAvatar(
          radius: 24,
          backgroundColor: HomeColors.cardFill,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? const Icon(Icons.person, color: HomeColors.green)
              : null,
        ),

        const SizedBox(width: 12),

        // الترحيب
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا، $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.green,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'نتمنى لحيواناتك صحة أفضل',
                style: TextStyle(
                  fontSize: 12,
                  color: HomeColors.subtitle,
                ),
              ),
            ],
          ),
        ),

        // جرس الإشعارات (على اليسار)
        GestureDetector(
          onTap: onNotificationsTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 32,
                color: HomeColors.green,
              ),
              if (notificationsCount > 0)
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}