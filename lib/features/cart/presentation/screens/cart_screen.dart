import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_app_bar.dart';
import '../widgets/cart_content.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_error_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => sl<CartCubit>()..watchItems(),
        child: const _CartView(),
      ),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CartAppBar(onClear: () => _confirmClear(context)),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.isLoading && state.items.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.errorMessage != null && state.items.isEmpty) {
              return CartErrorView(
                message: state.errorMessage!,
                onRetry: () => context.read<CartCubit>().watchItems(),
              );
            }

            if (state.items.isEmpty) {
              return CartEmptyState(onBrowse: () => _browseStore(context));
            }

            return CartContent(
              state: state,
              onCheckout: () => _showCheckoutMessage(context),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إفراغ السلة؟'),
        content: const Text('سيتم حذف جميع المنتجات من سلتك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('إفراغ السلة'),
          ),
        ],
      ),
    );
    if (shouldClear != true || !context.mounted) return;

    final cleared = await context.read<CartCubit>().clearItems();
    if (!context.mounted || cleared) return;
    _showMessage(context, context.read<CartCubit>().state.errorMessage);
  }

  void _browseStore(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.store);
    }
  }

  void _showCheckoutMessage(BuildContext context) {
    _showMessage(
      context,
      'إتمام الطلب سيكون متاحًا بعد تجهيز شاشة الشحن والدفع.',
    );
  }

  void _showMessage(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
