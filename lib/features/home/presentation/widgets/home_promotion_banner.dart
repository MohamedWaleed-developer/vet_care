import 'package:flutter/material.dart';

class HomePromotionBanner extends StatelessWidget {
  final VoidCallback onStoreTap;

  const HomePromotionBanner({super.key, required this.onStoreTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF267D68), Color(0xFF1E6554)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'كل احتياجات أليفك في مكان واحد',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'منتجات مختارة لرعاية أفضل كل يوم',
            style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onStoreTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('تسوق الآن'),
          ),
        ],
      ),
    );
  }
}
