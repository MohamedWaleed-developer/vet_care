import '../datasources/store_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;

  StoreRepository(this._remoteDataSource);

  Stream<List<ProductModel>> watchProducts() =>
      _remoteDataSource.watchProducts();

  Stream<List<CategoryModel>> watchCategories() =>
      _remoteDataSource.watchCategories();

  Stream<ProductModel?> watchProduct(String productId) =>
      _remoteDataSource.watchProduct(productId);

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    String? variant,
  }) => _remoteDataSource.addToCart(
    product,
    quantity: quantity,
    variant: variant,
  );
}
