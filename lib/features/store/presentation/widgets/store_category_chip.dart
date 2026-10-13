import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StoreCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StoreCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? AppColors.primaryDark : AppColors.border,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.secondaryText,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
