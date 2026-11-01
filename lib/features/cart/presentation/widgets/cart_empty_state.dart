import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CartEmptyState extends StatelessWidget {
  final VoidCallback onBrowse;

  const CartEmptyState({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 104.w,
            height: 104.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'سلة التسوق فارغة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.mainText,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'لم تضف أي منتجات إلى سلتك بعد. تصفح المتجر واختر ما يحتاجه أليفك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryText,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'تصفح المتجر الآن',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
