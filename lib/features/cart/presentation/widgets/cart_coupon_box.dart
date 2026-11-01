import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CartCouponBox extends StatefulWidget {
  const CartCouponBox({super.key});

  @override
  State<CartCouponBox> createState() => _CartCouponBoxState();
}

class _CartCouponBoxState extends State<CartCouponBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 38.h,
            child: FilledButton(
              onPressed: () => _showCouponMessage(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'تطبيق',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                hintText: 'أدخل كود الخصم',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponMessage(BuildContext context) {
    final message = _controller.text.trim().isEmpty
        ? 'أدخل كود الخصم أولاً.'
        : 'تفعيل أكواد الخصم غير متاح الآن.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
