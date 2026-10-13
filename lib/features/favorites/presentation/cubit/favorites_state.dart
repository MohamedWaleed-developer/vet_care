import '../../../store/data/models/product_model.dart';

class FavoritesState {
  final List<ProductModel> products;
  final Set<String> pendingProductIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.products = const [],
    this.pendingProductIds = const {},
    this.isLoading = true,
    this.errorMessage,
  });

  Set<String> get productIds => products.map((product) => product.id).toSet();

  FavoritesState copyWith({
    List<ProductModel>? products,
    Set<String>? pendingProductIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      FavoritesState(
        products: products ?? this.products,
        pendingProductIds: pendingProductIds ?? this.pendingProductIds,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
