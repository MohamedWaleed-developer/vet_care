import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepository(this._remoteDataSource);

  Stream<List<CartItemModel>> watchItems() => _remoteDataSource.watchItems();

  Future<List<CartItemModel>> getItems() => _remoteDataSource.getItems();

  Future<void> addItems(List<CartItemModel> items) =>
      _remoteDataSource.addItems(items);

  Future<void> updateQuantity(String itemId, int quantity) =>
      _remoteDataSource.updateQuantity(itemId, quantity);

  Future<void> removeItem(String itemId) =>
      _remoteDataSource.removeItem(itemId);

  Future<void> clearItems() => _remoteDataSource.clearItems();
}
