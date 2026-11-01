import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool isPending;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isPending,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AppImage(
                imageUrl: item.imageUrl,
                width: 76.w,
                height: 76.w,
                borderRadius: BorderRadius.circular(12.r),
              ),
              if (isPending)
                Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainText,
                  ),
                ),
                if (item.variant?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'الحجم ${item.variant}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Text(
                  AppFormatters.currency(
                    item.unitPrice.toDouble(),
                    currency: 'ج.م',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (item.quantity > 1) ...[
                  SizedBox(height: 3.h),
                  Text(
                    'الإجمالي: ${AppFormatters.currency(item.totalPrice.toDouble(), currency: 'ج.م')}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'حذف المنتج',
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20.sp,
                ),
                onPressed: isPending ? null : onRemove,
              ),
              SizedBox(height: 6.h),
              _QuantityControl(
                quantity: item.quantity,
                enabled: !isPending,
                onAdd: () => onQuantityChanged(item.quantity + 1),
                onRemove: () => onQuantityChanged(item.quantity - 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final bool enabled;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControl({
    required this.quantity,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(icon: Icons.add, enabled: enabled, onTap: onAdd),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.mainText,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.remove,
            enabled: enabled,
            onTap: onRemove,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(minWidth: 30.w, minHeight: 32.h),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 14.sp, color: AppColors.mainText),
      onPressed: enabled ? onTap : null,
    );
  }
}
