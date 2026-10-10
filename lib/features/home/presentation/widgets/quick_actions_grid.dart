import 'package:flutter/material.dart';

import '../home_colors.dart';

/// الأزرار الأربعة: التطعيمات / حيواناتي / المتجر / الخدمات
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onVaccinesTap;
  final VoidCallback? onMyPetsTap;
  final VoidCallback? onStoreTap;
  final VoidCallback? onServicesTap;

  const QuickActionsGrid({
    super.key,
    this.onVaccinesTap,
    this.onMyPetsTap,
    this.onStoreTap,
    this.onServicesTap,
  });

  @override
  Widget build(BuildContext context) {
    // في RTL أول عنصر بيظهر على اليمين
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'التطعيمات',
                icon: Icons.vaccines,
                onTap: onVaccinesTap,
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: _ActionCard(
                title: 'حيواناتي',
                icon: Icons.pets,
                onTap: onMyPetsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'المتجر',
                icon: Icons.shopping_cart,
                onTap: onStoreTap,
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: _ActionCard(
                title: 'الخدمات',
                icon: Icons.medical_services,
                onTap: onServicesTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: HomeColors.cardFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HomeColors.cardBorder, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: HomeColors.green),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HomeColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}