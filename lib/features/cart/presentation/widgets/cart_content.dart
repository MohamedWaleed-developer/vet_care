import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/cart_state.dart';
import 'cart_items_list.dart';
import 'cart_summary.dart';

class CartContent extends StatelessWidget {
  final CartState state;
  final VoidCallback onCheckout;

  const CartContent({super.key, required this.state, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.errorMessage != null)
          _InlineError(message: state.errorMessage!),
        Expanded(child: CartItemsList(state: state)),
        CartSummary(
          subtotal: state.subtotal,
          deliveryFee: CartState.standardDeliveryFee,
          total: state.total,
          isBusy: state.isClearing,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 0),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF8A5300), fontSize: 12),
      ),
    );
  }
}
