import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/product_model.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<ProductDetailsCubit>()..watchProduct(productId),
          ),
          BlocProvider(create: (_) => sl<FavoritesCubit>()..watchFavorites()),
        ],
        child: _ProductDetailsView(productId: productId),
      ),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  final String productId;

  const _ProductDetailsView({required this.productId});

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  var _quantity = 1;
  String? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            builder: (context, state) => switch (state) {
              ProductDetailsLoaded(:final product) => FavoriteButton(
                  product: product,
                  iconSize: 22,
                ),
              _ => const SizedBox(width: 12),
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            return switch (state) {
              ProductDetailsLoading() => const AppLoader(),
              ProductDetailsFailure(:final message) => AppError(
                  message: message,
                  onRetry: () => context
                      .read<ProductDetailsCubit>()
                      .watchProduct(widget.productId),
                ),
              ProductDetailsUnavailable() => const AppEmpty(
                  icon: Icons.inventory_2_outlined,
                  message: 'المنتج غير متاح حالياً',
                ),
              ProductDetailsLoaded(:final product) => _ProductContent(
                  product: product,
                  quantity: _quantity,
                  selectedVariant: _selectedVariant,
                  onQuantityChanged: (value) =>
                      setState(() => _quantity = value),
                  onVariantChanged: (value) =>
                      setState(() => _selectedVariant = value),
                  onAddToCart: () => _addToCart(context, product),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    final added = await context.read<ProductDetailsCubit>().addToCart(
          product,
          quantity: _quantity,
          variant: _selectedVariant,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added
              ? 'تمت إضافة المنتج إلى السلة'
              : 'سجّل الدخول أولاً لإضافة المنتجات إلى السلة'),
        ),
      );
  }
}

class _ProductContent extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final String? selectedVariant;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String?> onVariantChanged;
  final VoidCallback onAddToCart;

  const _ProductContent({
    required this.product,
    required this.quantity,
    required this.selectedVariant,
    required this.onQuantityChanged,
    required this.onVariantChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.imageUrls.isEmpty ? const [''] : product.imageUrls;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductGallery(images: images),
                const SizedBox(height: 20),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainText,
                    height: 1.4,
                  ),
                ),
                if (product.rating > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: Color(0xFFF4B740)),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFFB8790C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewsCount} تقييم)',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _ProductPrice(
                  price: product.price,
                  previousPrice: product.previousPrice,
                ),
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'الاختيارات المتاحة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.variants.map((variant) {
                      final selected = selectedVariant == variant;
                      return ChoiceChip(
                        label: Text(variant),
                        selected: selected,
                        onSelected: (_) => onVariantChanged(variant),
                        selectedColor: AppColors.primaryDark,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.mainText,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'الكمية',
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _QuantityControl(
                      quantity: quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'الوصف',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainText,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.description.isEmpty
                      ? 'لا يوجد وصف متاح لهذا المنتج.'
                      : product.description,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                if (product.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ExpansionTile(
                      title: const Text(
                        'المكونات والتركيبة الغذائية',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainText,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            product.ingredients,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: product.variants.isNotEmpty && selectedVariant == null
                    ? null
                    : onAddToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: const Text('إضافة إلى السلة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGallery extends StatefulWidget {
  final List<String> images;

  const _ProductGallery({required this.images});

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => AppImage(
                imageUrl: widget.images[index],
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (widget.images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final selected = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selected ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryDark : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductPrice extends StatelessWidget {
  final num price;
  final num? previousPrice;

  const _ProductPrice({required this.price, required this.previousPrice});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.##', 'ar_EG');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(
          '${formatter.format(price)} ج.م',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (previousPrice != null && previousPrice! > price)
          Text(
            '${formatter.format(previousPrice)} ج.م',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityControl({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add, size: 17),
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 17),
          ),
        ],
      ),
    );
  }
}
