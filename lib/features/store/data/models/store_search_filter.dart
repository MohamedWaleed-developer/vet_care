class StoreSearchFilter {
  final double minPrice;
  final double maxPrice;
  final int minRating;
  final Set<String> brands;

  const StoreSearchFilter({
    this.minPrice = 0,
    this.maxPrice = 0,
    this.minRating = 0,
    this.brands = const {},
  });

  bool get isActive =>
      minPrice > 0 || maxPrice > 0 || minRating > 0 || brands.isNotEmpty;

  StoreSearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    int? minRating,
    Set<String>? brands,
  }) {
    return StoreSearchFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      brands: brands ?? this.brands,
    );
  }
}
