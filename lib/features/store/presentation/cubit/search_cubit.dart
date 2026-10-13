import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_search_filter.dart';
import '../../data/repositories/store_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final StoreRepository _repository;
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;
  var _pendingStreams = 2;

  SearchCubit(this._repository) : super(const SearchState());

  void watchStore() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _pendingStreams = 2;
    emit(state.copyWith(isLoading: true, clearError: true));

    _productsSubscription = _repository.watchProducts().listen(
      (products) {
        if (_pendingStreams > 0) _pendingStreams--;
        emit(state.copyWith(
          allProducts: products,
          isLoading: _pendingStreams > 0,
        ));
      },
      onError: (_) => _setError(),
    );

    _categoriesSubscription = _repository.watchCategories().listen(
      (categories) {
        if (_pendingStreams > 0) _pendingStreams--;
        emit(state.copyWith(
          categories: categories,
          isLoading: _pendingStreams > 0,
        ));
      },
      onError: (_) => _setError(),
    );
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void applyFilter(StoreSearchFilter filter) =>
      emit(state.copyWith(filter: filter));

  void clearFilter() =>
      emit(state.copyWith(filter: const StoreSearchFilter()));

  Future<bool> addToCart(ProductModel product) async {
    try {
      await _repository.addToCart(product);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setError() {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'تعذر تحميل المنتجات. تحقق من اتصالك وحاول مرة أخرى.',
    ));
  }

  @override
  Future<void> close() async {
    await _productsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}
