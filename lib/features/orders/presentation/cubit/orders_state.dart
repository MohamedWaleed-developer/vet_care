import '../../data/models/order_model.dart';

class OrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;

  const OrdersState({
    this.orders = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      OrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
