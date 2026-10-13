import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../store/data/models/product_model.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final ProductModel product;
  final double iconSize;

  const FavoriteButton({
    super.key,
    required this.product,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.productIds.contains(product.id);
        final isPending = state.pendingProductIds.contains(product.id);

        return Material(
          color: AppColors.surface.withValues(alpha: 0.96),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
            visualDensity: VisualDensity.compact,
            onPressed: isPending
                ? null
                : () async {
                    final updated = await context
                        .read<FavoritesCubit>()
                        .toggleFavorite(product);
                    if (!updated && context.mounted) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              context.read<FavoritesCubit>().state.errorMessage ??
                                  'سجّل الدخول أولاً لحفظ المنتجات في المفضلة',
                            ),
                          ),
                        );
                    }
                  },
            icon: isPending
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                    size: iconSize,
                    color: isFavorite ? AppColors.error : AppColors.secondaryText,
                  ),
          ),
        );
      },
    );
  }
}
