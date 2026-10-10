import 'package:flutter/material.dart';

import '../home_colors.dart';

/// كارت "موعد تطعيم قادم"
class UpcomingVaccineCard extends StatelessWidget {
  final String vaccineName; // مثال: التطعيم الرباعي
  final String petName; // مثال: تاتا
  final String date; // مثال: 11/11/2026
  final VoidCallback? onDetailsTap;

  const UpcomingVaccineCard({
    super.key,
    required this.vaccineName,
    required this.petName,
    required this.date,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeColors.warnFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.warnBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة التقويم (يمين)
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF8D6B0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 30,
              color: HomeColors.warnIcon,
            ),
          ),

          const SizedBox(width: 12),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'موعد تطعيم قادم',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: HomeColors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$vaccineName _ $petName',
                  style: const TextStyle(
                    fontSize: 13,
                    color: HomeColors.subtitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),

          // يسار: علامة تنبيه + زر التفاصيل
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 26,
                color: HomeColors.warnIcon,
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onDetailsTap,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: HomeColors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}