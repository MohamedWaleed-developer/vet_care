import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;
  StreamSubscription<List<OrderModel>>? _subscription;

  OrdersCubit(this._repository) : super(const OrdersState());

  void watchOrders() {
    _subscription?.cancel();
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchOrders().listen(
      (orders) => emit(state.copyWith(
        orders: orders,
        isLoading: false,
        clearError: true,
      )),
      onError: (_) => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل طلباتك. حاول مرة أخرى.',
      )),
    );
  }

  Future<OrderModel?> getOrder(String id) => _repository.getOrder(id);

  Future<void> reorder(OrderModel order) =>
      _repository.addOrderItemsToCart(order);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
