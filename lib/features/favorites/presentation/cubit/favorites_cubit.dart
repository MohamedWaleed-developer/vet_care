import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../store/data/models/product_model.dart';
import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;
  StreamSubscription<List<ProductModel>>? _subscription;

  FavoritesCubit(this._repository) : super(const FavoritesState());

  void watchFavorites() {
    _subscription?.cancel();
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchFavorites().listen(
      (products) => emit(state.copyWith(products: products, isLoading: false)),
      onError: (_) => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل المفضلة. تحقق من اتصالك وحاول مرة أخرى.',
      )),
    );
  }

  Future<bool> toggleFavorite(ProductModel product) async {
    if (state.pendingProductIds.contains(product.id)) return false;
    emit(state.copyWith(
      pendingProductIds: {...state.pendingProductIds, product.id},
      clearError: true,
    ));

    try {
      await _repository.toggleFavorite(product);
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          errorMessage: error is StateError
              ? 'سجّل الدخول أولاً لحفظ المنتجات في المفضلة.'
              : 'تعذر تحديث المفضلة. تحقق من اتصالك وحاول مرة أخرى.',
        ));
      }
      return false;
    } finally {
      if (!isClosed) {
        emit(state.copyWith(
          pendingProductIds: {...state.pendingProductIds}..remove(product.id),
        ));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
