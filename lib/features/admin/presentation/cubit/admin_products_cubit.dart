import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  final AdminRepository _repository;
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;
  var _pendingStreams = 2;

  AdminProductsCubit(this._repository) : super(const AdminProductsState());

  Future<void> start() async {
    emit(
      state.copyWith(
        status: AdminProductsStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final isAdmin = await _repository.isAdmin();
      if (!isAdmin) {
        emit(
          state.copyWith(
            status: AdminProductsStatus.failure,
            isAdmin: false,
            accessChecked: true,
            errorMessage: 'ليس لديك صلاحية الدخول إلى لوحة الإدارة.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isAdmin: true,
          accessChecked: true,
          status: AdminProductsStatus.loading,
        ),
      );
      _watchData();
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminProductsStatus.failure,
          accessChecked: true,
          errorMessage: 'تعذر التحقق من صلاحية الإدارة.',
        ),
      );
    }
  }

  void _watchData() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _pendingStreams = 2;

    _productsSubscription = _repository.watchAllProducts().listen((products) {
      emit(
        state.copyWith(
          products: products,
          status: _markLoaded(),
          clearError: true,
        ),
      );
    }, onError: (_) => _handleStreamError());

    _categoriesSubscription = _repository.watchCategories().listen((
      categories,
    ) {
      emit(
        state.copyWith(
          categories: categories,
          status: _markLoaded(),
          clearError: true,
        ),
      );
    }, onError: (_) => _handleStreamError());
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required num price,
    required String categoryId,
    required String brand,
    required String imageUrl,
    required List<String> imageUrls,
    required String ingredients,
    required List<String> variants,
    num? previousPrice,
    bool isAvailable = true,
  }) async {
    emit(
      state.copyWith(
        status: AdminProductsStatus.saving,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await _repository.createProduct(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        brand: brand,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        ingredients: ingredients,
        variants: variants,
        previousPrice: previousPrice,
        isAvailable: isAvailable,
      );
      emit(
        state.copyWith(
          status: AdminProductsStatus.ready,
          successMessage: 'تم إضافة المنتج بنجاح.',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminProductsStatus.failure,
          errorMessage: _mapError(error),
        ),
      );
      return false;
    }
  }

  Future<bool> updateProduct({
    required ProductModel existing,
    required String name,
    required String description,
    required num price,
    required String categoryId,
    required String brand,
    required String imageUrl,
    required List<String> imageUrls,
    required String ingredients,
    required List<String> variants,
    num? previousPrice,
    required bool isAvailable,
  }) async {
    emit(
      state.copyWith(
        status: AdminProductsStatus.saving,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await _repository.updateProduct(
        existing: existing,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        brand: brand,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        ingredients: ingredients,
        variants: variants,
        previousPrice: previousPrice,
        isAvailable: isAvailable,
      );
      emit(
        state.copyWith(
          status: AdminProductsStatus.ready,
          successMessage: 'تم تحديث المنتج بنجاح.',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminProductsStatus.failure,
          errorMessage: _mapError(error),
        ),
      );
      return false;
    }
  }

  Future<void> toggleAvailability(ProductModel product) async {
    final next = !product.isAvailable;
    emit(state.copyWith(clearError: true, clearSuccess: true));
    try {
      await _repository.setProductAvailability(
        productId: product.id,
        isAvailable: next,
      );
      emit(
        state.copyWith(
          status: AdminProductsStatus.ready,
          successMessage: next ? 'تم تفعيل المنتج.' : 'تم إيقاف المنتج.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminProductsStatus.failure,
          errorMessage: _mapError(error),
        ),
      );
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    emit(
      state.copyWith(
        status: AdminProductsStatus.saving,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await _repository.deleteProduct(product.id);
      emit(
        state.copyWith(
          status: AdminProductsStatus.ready,
          successMessage: 'تم حذف المنتج.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminProductsStatus.failure,
          errorMessage: _mapError(error),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  AdminProductsStatus _markLoaded() {
    if (_pendingStreams > 0) _pendingStreams--;
    return _pendingStreams > 0
        ? AdminProductsStatus.loading
        : AdminProductsStatus.ready;
  }

  void _handleStreamError() {
    emit(
      state.copyWith(
        status: AdminProductsStatus.failure,
        errorMessage: 'تعذر تحميل بيانات المنتجات. تحقق من اتصالك.',
      ),
    );
  }

  String _mapError(Object error) {
    if (error is StateError) return error.message;
    return 'حدث خطأ أثناء حفظ التغييرات. حاول مرة أخرى.';
  }

  @override
  Future<void> close() async {
    await _productsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}
