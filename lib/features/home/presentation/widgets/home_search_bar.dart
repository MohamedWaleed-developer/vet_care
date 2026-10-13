import 'package:flutter/material.dart';

import '../home_colors.dart';

/// شريط البحث
class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  const HomeSearchBar({super.key, this.onSubmitted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.cardBorder.withOpacity(0.6)),
      ),
      child: TextField(
        readOnly: onTap != null,
        onTap: onTap,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'ابحث عن منتج،دواء أو خدمة..',
          hintStyle: TextStyle(color: HomeColors.subtitle, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: HomeColors.cardBorder),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
