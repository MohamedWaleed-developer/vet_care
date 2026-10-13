import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/store_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final StoreRepository _repository;
  StreamSubscription<ProductModel?>? _subscription;

  ProductDetailsCubit(this._repository)
      : super(const ProductDetailsLoading());

  void watchProduct(String productId) {
    emit(const ProductDetailsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchProduct(productId).listen(
      (product) {
        if (product == null || !product.isAvailable) {
          emit(const ProductDetailsUnavailable());
        } else {
          emit(ProductDetailsLoaded(product));
        }
      },
      onError: (_) => emit(
        const ProductDetailsFailure(
          'تعذر تحميل تفاصيل المنتج. تحقق من اتصالك وحاول مرة أخرى.',
        ),
      ),
    );
  }

  Future<bool> addToCart(
    ProductModel product, {
    required int quantity,
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

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
