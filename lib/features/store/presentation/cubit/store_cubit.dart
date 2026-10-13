import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/store_repository.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreRepository _repository;
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;
  var _pendingStreams = 2;

  StoreCubit(this._repository) : super(const StoreState());

  void watchStore() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _pendingStreams = 2;
    emit(state.copyWith(isLoading: true, clearError: true));

    _productsSubscription = _repository.watchProducts().listen(
      (products) {
        emit(state.copyWith(products: products, isLoading: _markLoaded()));
      },
      onError: (_) => _handleError(),
    );

    _categoriesSubscription = _repository.watchCategories().listen(
      (categories) {
        emit(state.copyWith(categories: categories, isLoading: _markLoaded()));
      },
      onError: (_) => _handleError(),
    );
  }

  void selectCategory(String? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearSelectedCategory: categoryId == null,
    ));
  }

  Future<bool> addToCart(
    ProductModel product, {
    int quantity = 1,
    String? variant,
  }) async {
    try {
      await _repository.addToCart(
        product,
        quantity: quantity,
        variant: variant,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _markLoaded() {
    if (_pendingStreams > 0) _pendingStreams--;
    return _pendingStreams > 0;
  }

  void _handleError() {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'تعذر تحميل بيانات المتجر. تحقق من اتصالك وحاول مرة أخرى.',
    ));
  }

  @override
  Future<void> close() async {
    await _productsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}
