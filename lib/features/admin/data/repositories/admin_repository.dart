import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepository(this._remoteDataSource);

  Future<bool> isAdmin() => _remoteDataSource.isAdmin();

  Stream<List<ProductModel>> watchAllProducts() =>
      _remoteDataSource.watchAllProducts();

  Stream<List<CategoryModel>> watchCategories() =>
      _remoteDataSource.watchCategories();

  Future<void> createProduct({
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
  }) => _remoteDataSource.createProduct(
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

  Future<void> updateProduct({
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
  }) => _remoteDataSource.updateProduct(
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

  Future<void> setProductAvailability({
    required String productId,
    required bool isAvailable,
  }) => _remoteDataSource.setProductAvailability(
    productId: productId,
    isAvailable: isAvailable,
  );

  Future<void> deleteProduct(String productId) =>
      _remoteDataSource.deleteProduct(productId);
}
