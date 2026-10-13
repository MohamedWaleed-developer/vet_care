import 'package:flutter/material.dart';

import '../home_colors.dart';

/// بانر العرض الخاص
class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    this.title = 'خصم 20% على جميع اللقاحات',
    this.subtitle = 'حتى نهاية الشهر _احجز لقاحك',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: HomeColors.green,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F4A3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // وسم "عرض خاص" (يمين)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 16, color: HomeColors.green),
                  SizedBox(width: 6),
                  Text(
                    'عرض خاص',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomeColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFFD4E6DF)),
            ),
          ),

          const SizedBox(height: 4),

          // زر "تسوق الان" (يسار)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تسوق الان',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomeColors.green,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.keyboard_double_arrow_left,
                        size: 16, color: HomeColors.green),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}