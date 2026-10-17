import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../store/data/models/product_model.dart';
import '../cubit/admin_products_cubit.dart';
import '../cubit/admin_products_state.dart';
import '../widgets/admin_product_tile.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminProductsCubit>()..start(),
      child: const _AdminProductsView(),
    );
  }
}

class _AdminProductsView extends StatelessWidget {
  const _AdminProductsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('إدارة المنتجات')),
        floatingActionButton:
            BlocBuilder<AdminProductsCubit, AdminProductsState>(
              builder: (context, state) {
                if (!state.isAdmin) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('منتج جديد'),
                );
              },
            ),
        body: BlocConsumer<AdminProductsCubit, AdminProductsState>(
          listenWhen: (previous, current) =>
              previous.successMessage != current.successMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final message = state.successMessage ?? state.errorMessage;
            if (message == null || message.isEmpty) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            context.read<AdminProductsCubit>().clearMessages();
          },
          builder: (context, state) {
            if (!state.accessChecked ||
                state.status == AdminProductsStatus.loading ||
                state.status == AdminProductsStatus.initial) {
              return const AppLoader();
            }

            if (!state.isAdmin) {
              return _MessageBody(
                icon: Icons.lock_outline,
                message:
                    state.errorMessage ??
                    'ليس لديك صلاحية الدخول إلى لوحة الإدارة.',
              );
            }

            if (state.status == AdminProductsStatus.failure &&
                state.products.isEmpty) {
              return _MessageBody(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'تعذر تحميل المنتجات.',
              );
            }

            if (state.products.isEmpty) {
              return const _MessageBody(
                icon: Icons.inventory_2_outlined,
                message: 'لا توجد منتجات بعد. أضف أول منتج من الزر أدناه.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return AdminProductTile(
                  product: product,
                  categoryName: state.categoryNameFor(product.categoryId),
                  onEdit: () => _openForm(context, product: product),
                  onToggleAvailability: () => context
                      .read<AdminProductsCubit>()
                      .toggleAvailability(product),
                  onDelete: () => _confirmDelete(context, product),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {ProductModel? product}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminProductsCubit>(),
          child: AdminProductFormScreen(product: product),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف المنتج'),
          content: Text('هل تريد حذف «${product.name}» نهائياً؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AdminProductsCubit>().deleteProduct(product);
  }
}

class _MessageBody extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageBody({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.secondaryText),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
