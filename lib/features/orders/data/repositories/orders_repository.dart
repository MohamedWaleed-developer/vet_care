import '../../../checkout/data/models/checkout_draft.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepository(this._remoteDataSource);

  Stream<List<OrderModel>> watchOrders() => _remoteDataSource.watchOrders();

  Future<OrderModel?> getOrder(String orderId) =>
      _remoteDataSource.getOrder(orderId);

  Future<OrderModel> createOrderFromCart({
    required CheckoutDraft draft,
    required String paymentMethod,
    required String paymentStatus,
    String? transactionId,
  }) =>
      _remoteDataSource.createOrderFromCart(
        draft: draft,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
      );

  Future<void> addOrderItemsToCart(OrderModel order) =>
      _remoteDataSource.addOrderItemsToCart(order);
}
