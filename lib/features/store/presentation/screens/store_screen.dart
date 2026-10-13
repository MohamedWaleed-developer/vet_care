import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../cubit/store_cubit.dart';
import '../cubit/store_state.dart';
import '../widgets/product_card.dart';
import '../widgets/store_category_chip.dart';

class StoreScreen extends StatelessWidget {
  final String? initialCategoryId;

  const StoreScreen({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => sl<StoreCubit>()
          ..selectCategory(initialCategoryId)
          ..watchStore(),
        child: const _StoreView(),
      ),
    );
  }
}

class _StoreView extends StatelessWidget {
  const _StoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'متجر رعاية بيطرية',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: 'العودة',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'البحث',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.search),
          ),
          IconButton(
            tooltip: 'السلة',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            if (state.isLoading && state.products.isEmpty) {
              return const AppLoader();
            }

            if (state.errorMessage != null && state.products.isEmpty) {
              return AppError(
                message: state.errorMessage!,
                onRetry: () => context.read<StoreCubit>().watchStore(),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 8),
                _CategoryList(state: state),
                const SizedBox(height: 14),
                Expanded(
                  child: state.visibleProducts.isEmpty
                      ? const AppEmpty(
                          icon: Icons.storefront_outlined,
                          message: 'لا توجد منتجات متاحة في هذا القسم حالياً',
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            context.read<StoreCubit>().watchStore();
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 700 ? 3 : 2;
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                                itemCount: state.visibleProducts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  childAspectRatio: 0.64,
                                  crossAxisSpacing: 13,
                                  mainAxisSpacing: 13,
                                ),
                                itemBuilder: (context, index) {
                                  final product = state.visibleProducts[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(
                                      RouteNames.productDetails,
                                      arguments: product.id,
                                    ),
                                    onAddToCart: () async {
                                      final added = await context
                                          .read<StoreCubit>()
                                          .addToCart(product);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(added
                                                ? 'تمت إضافة ${product.name} إلى السلة'
                                                : 'سجّل الدخول أولاً لإضافة المنتجات إلى السلة'),
                                          ),
                                        );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final StoreState state;

  const _CategoryList({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return StoreCategoryChip(
              label: 'الكل',
              selected: state.selectedCategoryId == null,
              onTap: () => context.read<StoreCubit>().selectCategory(null),
            );
          }

          final category = state.categories[index - 1];
          return StoreCategoryChip(
            label: category.name,
            selected: state.selectedCategoryId == category.id,
            onTap: () =>
                context.read<StoreCubit>().selectCategory(category.id),
          );
        },
      ),
    );
  }
}
