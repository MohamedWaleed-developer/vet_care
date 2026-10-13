import '../../../store/data/models/product_model.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepository(this._remoteDataSource);

  Stream<List<ProductModel>> watchFavorites() =>
      _remoteDataSource.watchFavorites();

  Future<void> toggleFavorite(ProductModel product) =>
      _remoteDataSource.toggleFavorite(product);
}
