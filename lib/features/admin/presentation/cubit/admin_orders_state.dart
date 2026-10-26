import '../../../orders/data/models/order_model.dart';

enum AdminOrdersStatus {
  initial,
  loading,
  ready,
  updating,
  failure,
}

enum AdminOrdersFilter {
  all,
  newOrders,
  active,
  completed,
  cancelled,
}

class AdminOrdersState {
  final AdminOrdersStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;
  final String? successMessage;
  final bool isAdmin;
  final bool accessChecked;
  final String searchQuery;
  final AdminOrdersFilter filter;

  const AdminOrdersState({
    this.status = AdminOrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.successMessage,
    this.isAdmin = false,
    this.accessChecked = false,
    this.searchQuery = '',
    this.filter = AdminOrdersFilter.all,
  });

  List<OrderModel> get filteredOrders {
    final query = searchQuery.trim().toLowerCase();

    return orders.where((order) {
      final matchesSearch = query.isEmpty ||
          order.orderNumber.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.phoneNumber.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        AdminOrdersFilter.all => true,
        AdminOrdersFilter.newOrders =>
        order.status == 'pending' || order.status == 'confirmed',
        AdminOrdersFilter.active => order.isActive,
        AdminOrdersFilter.completed => order.isCompleted,
        AdminOrdersFilter.cancelled => order.isCancelled,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get totalOrders => orders.length;

  int get newOrdersCount => orders
      .where((order) =>
  order.status == 'pending' || order.status == 'confirmed')
      .length;

  int get completedOrdersCount =>
      orders.where((order) => order.isCompleted).length;

  int get cancelledOrdersCount =>
      orders.where((order) => order.isCancelled).length;

  AdminOrdersState copyWith({
    AdminOrdersStatus? status,
    List<OrderModel>? orders,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isAdmin,
    bool? accessChecked,
    String? searchQuery,
    AdminOrdersFilter? filter,
  }) {
    return AdminOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
      clearSuccess ? null : successMessage ?? this.successMessage,
      isAdmin: isAdmin ?? this.isAdmin,
      accessChecked: accessChecked ?? this.accessChecked,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }
}