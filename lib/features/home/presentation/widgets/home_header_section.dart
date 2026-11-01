import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeHeaderSection extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;

  const HomeHeaderSection({
    super.key,
    required this.userName,
    required this.photoUrl,
    required this.onMenuTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isEmpty ? 'في Vet Care' : userName;

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'القائمة',
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl!),
          child: photoUrl == null
              ? const Icon(Icons.person_outline, color: AppColors.primaryDark)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أهلًا بك،',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'الإشعارات',
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
