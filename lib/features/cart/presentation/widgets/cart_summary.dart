import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class CartSummary extends StatelessWidget {
  final num subtotal;
  final num deliveryFee;
  final num total;
  final bool isBusy;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.isBusy,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final formattedSubtotal = AppFormatters.currency(
      subtotal.toDouble(),
      currency: 'ج.م',
    );
    final formattedDeliveryFee = AppFormatters.currency(
      deliveryFee.toDouble(),
      currency: 'ج.م',
    );
    final formattedTotal = AppFormatters.currency(
      total.toDouble(),
      currency: 'ج.م',
    );

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'ملخص الطلب',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.mainText,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _SummaryRow(title: 'المجموع الفرعي', value: formattedSubtotal),
          SizedBox(height: 8.h),
          _SummaryRow(title: 'التوصيل العادي', value: formattedDeliveryFee),
          Divider(height: 24.h, color: AppColors.border),
          _SummaryRow(
            title: 'المجموع الإجمالي',
            value: formattedTotal,
            emphasize: true,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: isBusy ? null : onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'إتمام الطلب',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: emphasize ? 15.sp : 13.sp,
            fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
            color: emphasize ? AppColors.mainText : AppColors.secondaryText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: emphasize ? 16.sp : 13.sp,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: emphasize
                  ? AppColors.primaryDark
                  : AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
