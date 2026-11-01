import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClear;

  const CartAppBar({super.key, required this.onClear});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 64.w,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'رجوع',
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: AppColors.mainText,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, RouteNames.store);
              }
            },
          ),
        ),
      ),
      title: Text(
        'سلة التسوق',
        style: TextStyle(
          color: AppColors.mainText,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'طلباتي',
          icon: Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 22.sp,
          ),
          onPressed: () => Navigator.pushNamed(context, RouteNames.orders),
        ),
        BlocBuilder<CartCubit, CartState>(
          buildWhen: (previous, current) =>
              previous.items.length != current.items.length ||
              previous.isClearing != current.isClearing,
          builder: (context, state) {
            if (state.items.isEmpty) return SizedBox(width: 12.w);
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: IconButton(
                tooltip: 'إفراغ السلة',
                icon: state.isClearing
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.delete_outline,
                        color: AppColors.secondaryText,
                        size: 24.sp,
                      ),
                onPressed: state.isClearing ? null : onClear,
              ),
            );
          },
        ),
      ],
    );
  }
}
