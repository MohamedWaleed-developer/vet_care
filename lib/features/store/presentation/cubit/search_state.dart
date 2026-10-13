import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_search_filter.dart';

class SearchState {
  final List<ProductModel> allProducts;
  final List<CategoryModel> categories;
  final String query;
  final StoreSearchFilter filter;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.allProducts = const [],
    this.categories = const [],
    this.query = '',
    this.filter = const StoreSearchFilter(),
    this.isLoading = true,
    this.errorMessage,
  });

  List<ProductModel> get results {
    final normalizedQuery = _normalize(query);
    return allProducts.where((product) {
      final category = _categoryName(product.categoryId);
      final searchable = _normalize(
        '${product.name} ${product.description} ${product.brand} ${category ?? ''}',
      );
      final matchesQuery =
          normalizedQuery.isEmpty || searchable.contains(normalizedQuery);
      final matchesPrice =
          product.price >= filter.minPrice &&
          (filter.maxPrice <= 0 || product.price <= filter.maxPrice);
      final matchesRating = product.rating >= filter.minRating;
      final matchesBrand =
          filter.brands.isEmpty || filter.brands.contains(product.brand);
      return matchesQuery && matchesPrice && matchesRating && matchesBrand;
    }).toList();
  }

  List<ProductModel> get recommendations => allProducts.take(4).toList();

  List<String> get brands => allProducts
      .map((product) => product.brand)
      .where((brand) => brand.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  double get maxPrice => allProducts.fold<double>(
        100,
        (maximum, product) =>
            product.price.toDouble() > maximum
                ? product.price.toDouble()
                : maximum,
      );

  SearchState copyWith({
    List<ProductModel>? allProducts,
    List<CategoryModel>? categories,
    String? query,
    StoreSearchFilter? filter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      allProducts: allProducts ?? this.allProducts,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ى', 'ي');
  }

  String? _categoryName(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return null;
  }
}
