import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orders/data/models/order_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_orders_state.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final AdminRepository _repository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  AdminOrdersCubit(this._repository) : super(const AdminOrdersState());

  Future<void> start() async {
    emit(
      state.copyWith(
        status: AdminOrdersStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final isAdmin = await _repository.isAdmin();

      if (!isAdmin) {
        emit(
          state.copyWith(
            status: AdminOrdersStatus.failure,
            isAdmin: false,
            accessChecked: true,
            errorMessage: 'ليس لديك صلاحية الدخول إلى إدارة الطلبات.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isAdmin: true,
          accessChecked: true,
          status: AdminOrdersStatus.loading,
        ),
      );

      _watchOrders();
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminOrdersStatus.failure,
          accessChecked: true,
          errorMessage: 'تعذر التحقق من صلاحية الإدارة.',
        ),
      );
    }
  }

  void _watchOrders() {
    _ordersSubscription?.cancel();

    _ordersSubscription = _repository.watchAllOrders().listen(
          (orders) {
        emit(
          state.copyWith(
            orders: orders,
            status: AdminOrdersStatus.ready,
            clearError: true,
          ),
        );
      },
      onError: (_) {
        emit(
          state.copyWith(
            status: AdminOrdersStatus.failure,
            errorMessage: 'تعذر تحميل الطلبات. تحقق من اتصالك.',
          ),
        );
      },
    );
  }

  void search(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        clearError: true,
      ),
    );
  }

  void changeFilter(AdminOrdersFilter filter) {
    emit(
      state.copyWith(
        filter: filter,
        clearError: true,
      ),
    );
  }

  Future<bool> updateStatus({
    required String orderId,
    required String status,
  }) async {
    emit(
      state.copyWith(
        status: AdminOrdersStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      emit(
        state.copyWith(
          status: AdminOrdersStatus.ready,
          successMessage: 'تم تحديث حالة الطلب بنجاح.',
        ),
      );

      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminOrdersStatus.ready,
          errorMessage: _mapError(error),
        ),
      );

      return false;
    }
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  String _mapError(Object error) {
    if (error is StateError) return error.message;
    if (error is ArgumentError) return error.message?.toString() ?? 'حالة الطلب غير صحيحة.';
    return 'حدث خطأ أثناء تحديث الطلب. حاول مرة أخرى.';
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    return super.close();
  }
}