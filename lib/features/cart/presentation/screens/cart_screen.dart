import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/cart_item_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: BlocProvider(
        create: (_) => sl<CartCubit>()..watchItems(),
        child: const _CartView(),
      ),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  static const _primary = Color(0xFF1E6554);
  static const _background = Color(0xFFF8F9FA);
  static final _currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.isLoading && state.items.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: _primary),
              );
            }

            if (state.errorMessage != null && state.items.isEmpty) {
              return _CartError(
                message: state.errorMessage!,
                onRetry: () => context.read<CartCubit>().watchItems(),
              );
            }

            if (state.items.isEmpty) {
              return _EmptyCart(onBrowse: () => _browseStore(context));
            }

            return Column(
              children: [
                if (state.errorMessage != null)
                  _InlineError(message: state.errorMessage!),
                Expanded(child: _CartItemsList(state: state)),
                _CartSummary(
                  subtotal: state.subtotal,
                  isBusy: state.isClearing,
                  onCheckout: () => _showCheckoutMessage(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black87,
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
      title: const Text(
        'سلة التسوق',
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'طلباتي',
          icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1E6554)),
          onPressed: () => Navigator.pushNamed(context, RouteNames.orders),
        ),
        BlocBuilder<CartCubit, CartState>(
          buildWhen: (previous, current) =>
              previous.items.length != current.items.length ||
              previous.isClearing != current.isClearing,
          builder: (context, state) {
            if (state.items.isEmpty) return const SizedBox(width: 12);
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: IconButton(
                tooltip: 'إفراغ السلة',
                icon: state.isClearing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primary,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                onPressed: state.isClearing
                    ? null
                    : () => _confirmClear(context),
              ),
            );
          },
        ),
      ],
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
    Navigator.pushNamed(context, RouteNames.checkout);
  }

  void _showMessage(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F3EF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: _CartView._primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'سلة التسوق فارغة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'لم تقم بإضافة أي منتجات إلى سلتك بعد. تسوق من\nمجموعتنا المميزة لتوفير الرعاية الأفضل لأليفك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: _CartView._primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'تصفح المتجر الآن',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CartItemsList extends StatelessWidget {
  final CartState state;

  const _CartItemsList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: state.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == state.items.length) return const _CouponBox();
        final item = state.items[index];
        return _CartItemTile(
          item: item,
          isPending: state.pendingItemIds.contains(item.id),
          onRemove: () => _removeItem(context, item),
          onQuantityChanged: (quantity) =>
              context.read<CartCubit>().changeQuantity(item, quantity),
        );
      },
    );
  }

  Future<void> _removeItem(BuildContext context, CartItemModel item) async {
    final removed = await context.read<CartCubit>().removeItem(item.id);
    if (!context.mounted || removed) return;
    final message = context.read<CartCubit>().state.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _CouponBox extends StatefulWidget {
  const _CouponBox();

  @override
  State<_CouponBox> createState() => _CouponBoxState();
}

class _CouponBoxState extends State<_CouponBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        _controller.text.trim().isEmpty
                            ? 'اكتب كود الخصم أولاً.'
                            : 'تفعيل أكواد الخصم هيكون متاحًا بعد تجهيز العروض.',
                      ),
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _CartView._primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: const Text(
                'تطبيق',
                style: TextStyle(
                  fontSize: 13,
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
              textDirection: ui.TextDirection.ltr,
              decoration: const InputDecoration(
                hintText: 'أدخل كود الخصم',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool isPending;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const _CartItemTile({
    required this.item,
    required this.isPending,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'حذف المنتج',
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                onPressed: isPending ? null : onRemove,
              ),
              const SizedBox(height: 12),
              _QuantityControl(
                quantity: item.quantity,
                enabled: !isPending,
                onAdd: () => onQuantityChanged(item.quantity + 1),
                onRemove: () => onQuantityChanged(item.quantity - 1),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (item.variant != null && item.variant!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'الحجم ${item.variant}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _CartView._currencyFormat.format(item.unitPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _CartView._primary,
                  ),
                ),
                if (item.quantity > 1) ...[
                  const SizedBox(height: 3),
                  Text(
                    'الإجمالي: ${_CartView._currencyFormat.format(item.totalPrice)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              AppImage(
                imageUrl: item.imageUrl,
                width: 68,
                height: 68,
                borderRadius: BorderRadius.circular(12),
              ),
              if (isPending)
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _CartView._primary,
                    ),
                  ),
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
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.add,
            enabled: enabled,
            onTap: onAdd,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
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
      constraints: const BoxConstraints(minWidth: 28, minHeight: 30),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 14, color: const Color(0xFF1E293B)),
      onPressed: enabled ? onTap : null,
    );
  }
}

class _CartSummary extends StatelessWidget {
  final num subtotal;
  final bool isBusy;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.isBusy,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
          color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            title: 'المجموع الفرعي',
            value: _CartView._currencyFormat.format(subtotal),
          ),
          const SizedBox(height: 8),
          const _SummaryRow(
            title: 'التوصيل',
            value: 'يحسب عند إتمام الطلب',
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
          _SummaryRow(
            title: 'الإجمالي قبل التوصيل',
            value: _CartView._currencyFormat.format(subtotal),
            emphasize: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isBusy ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _CartView._primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'إتمام الطلب',
                style: TextStyle(
                  fontSize: 15,
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
            fontSize: emphasize ? 16 : 13,
            fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
            color: emphasize ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: emphasize ? 17 : 13,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w600,
              color: emphasize ? _CartView._primary : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('حاول مرة أخرى')),
          ],
        ),
      ),
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF8A5300), fontSize: 12),
      ),
    );
  }
}
