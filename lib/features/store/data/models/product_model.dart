class ProductModel {
  final String id;
  final String name;
  final String description;
  final num price;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final String brand;
  final bool isAvailable;
  final num? previousPrice;
  final String ingredients;
  final List<String> variants;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
    required this.brand,
    required this.isAvailable,
    required this.previousPrice,
    required this.ingredients,
    required this.variants,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    final rawPrice = data['price'];
    final rawRating = data['rating'];
    final rawReviews = data['reviewsCount'];
    final rawImages = data['imageUrls'];
    final images = rawImages is List
        ? rawImages.map(_stringValue).where((url) => url.isNotEmpty).toList()
        : <String>[];
    final imageUrl = _stringValue(data['imageUrl'] ?? data['image']);
    if (images.isEmpty && imageUrl.isNotEmpty) images.add(imageUrl);
    final rawVariants = data['variants'];
    final rawPreviousPrice = data['previousPrice'];

    return ProductModel(
      id: id,
      name: _stringValue(data['name'] ?? data['title']),
      description: _stringValue(data['description']),
      price: rawPrice is num ? rawPrice : num.tryParse('$rawPrice') ?? 0,
      rating: rawRating is num
          ? rawRating.toDouble()
          : double.tryParse('$rawRating') ?? 0,
      reviewsCount: rawReviews is num
          ? rawReviews.toInt()
          : int.tryParse('$rawReviews') ?? 0,
      imageUrl: imageUrl,
      imageUrls: images,
      categoryId: _stringValue(data['categoryId'] ?? data['category']),
      brand: _stringValue(data['brand']),
      isAvailable: data['isActive'] != false && data['isAvailable'] != false,
      previousPrice: rawPreviousPrice is num
          ? rawPreviousPrice
          : num.tryParse('$rawPreviousPrice'),
      ingredients: _stringValue(data['ingredients']),
      variants: rawVariants is List
          ? rawVariants.map(_stringValue).where((value) => value.isNotEmpty).toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'imageUrl': imageUrl,
        'imageUrls': imageUrls,
        'categoryId': categoryId,
        'brand': brand,
        'isActive': isAvailable,
        'previousPrice': previousPrice,
        'ingredients': ingredients,
        'variants': variants,
      };

  static String _stringValue(dynamic value) => value?.toString().trim() ?? '';
}
