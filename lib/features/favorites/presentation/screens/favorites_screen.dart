import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../store/presentation/cubit/store_cubit.dart';
import '../../../store/presentation/widgets/product_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<FavoritesCubit>()..watchFavorites(),
          ),
          BlocProvider(create: (_) => sl<StoreCubit>()),
        ],
        child: const _FavoritesView(),
      ),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'المفضلة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.isLoading && state.products.isEmpty) {
              return const AppLoader();
            }
            if (state.errorMessage != null && state.products.isEmpty) {
              return AppError(
                message: state.errorMessage!,
                onRetry: () => context.read<FavoritesCubit>().watchFavorites(),
              );
            }
            if (state.products.isEmpty) return const _EmptyFavorites();

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: state.products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.64,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                  ),
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).pushNamed(
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
            );
          },
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'لسه مفيش منتجات في المفضلة',
              style: TextStyle(
                color: AppColors.mainText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اضغط على علامة القلب في أي منتج عشان تحفظه هنا.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, height: 1.6),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.store),
              child: const Text('تصفح المتجر'),
            ),
          ],
        ),
      ),
    );
  }
}
