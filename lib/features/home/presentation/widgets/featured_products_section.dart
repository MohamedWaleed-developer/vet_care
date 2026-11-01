import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/presentation/cubit/store_cubit.dart';
import '../../../store/presentation/cubit/store_state.dart';

class FeaturedProductsSection extends StatelessWidget {
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;

  const FeaturedProductsSection({
    super.key,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.isLoading && state.products.isEmpty) {
          return const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text('المنتجات المميزة ستظهر هنا عند توفرها.'),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;
            final products = state.products.take(4).toList();

            return GridView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) => _FeaturedProductCard(
                product: products[index],
                onTap: () => onProductTap(products[index]),
                onAddToCart: () => onAddToCart(products[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _FeaturedProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppImage(
                  imageUrl: product.imageUrl,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${product.price} ج.م',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 17),
                    tooltip: 'أضف للسلة',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
