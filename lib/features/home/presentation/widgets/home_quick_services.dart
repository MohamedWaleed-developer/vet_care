import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeQuickServices extends StatelessWidget {
  final VoidCallback onStoreTap;
  final VoidCallback onVaccinationsTap;
  final VoidCallback onServicesTap;
  final VoidCallback onOrdersTap;

  const HomeQuickServices({
    super.key,
    required this.onStoreTap,
    required this.onVaccinationsTap,
    required this.onServicesTap,
    required this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ServiceItem(
          title: 'المتجر',
          icon: Icons.medication_outlined,
          iconColor: const Color(0xFFEF4444),
          background: const Color(0xFFFFECEF),
          onTap: onStoreTap,
        ),
        _ServiceItem(
          title: 'التطعيمات',
          icon: Icons.verified_user_outlined,
          iconColor: const Color(0xFF2563EB),
          background: const Color(0xFFEFF6FF),
          onTap: onVaccinationsTap,
        ),
        _ServiceItem(
          title: 'الخدمات',
          icon: Icons.support_agent_outlined,
          iconColor: const Color(0xFFF59E0B),
          background: const Color(0xFFFEF3C7),
          onTap: onServicesTap,
        ),
        _ServiceItem(
          title: 'طلباتي',
          icon: Icons.local_shipping_outlined,
          iconColor: AppColors.primaryDark,
          background: AppColors.primaryLight,
          onTap: onOrdersTap,
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: background,
                    child: Icon(icon, color: iconColor, size: 21),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
