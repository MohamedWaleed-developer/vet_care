import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_coupon_box.dart';
import 'cart_item_tile.dart';

class CartItemsList extends StatelessWidget {
  final CartState state;

  const CartItemsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 16.h),
      itemCount: state.items.length + 1,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == state.items.length) return const CartCouponBox();
        final item = state.items[index];
        return CartItemTile(
          item: item,
          isPending: state.pendingItemIds.contains(item.id),
          onRemove: () => _removeItem(context, item.id),
          onQuantityChanged: (quantity) =>
              context.read<CartCubit>().changeQuantity(item, quantity),
        );
      },
    );
  }

  Future<void> _removeItem(BuildContext context, String itemId) async {
    final removed = await context.read<CartCubit>().removeItem(itemId);
    if (!context.mounted || removed) return;
    final message = context.read<CartCubit>().state.errorMessage;
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
