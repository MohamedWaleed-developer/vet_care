import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

class StoreState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final String? errorMessage;

  const StoreState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.isLoading = true,
    this.errorMessage,
  });

  List<ProductModel> get visibleProducts {
    final categoryId = selectedCategoryId;
    if (categoryId == null) return products;
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  StoreState copyWith({
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StoreState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
