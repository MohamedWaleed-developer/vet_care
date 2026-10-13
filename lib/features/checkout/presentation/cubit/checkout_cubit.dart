import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/payment/payment_result.dart';
import '../../../../core/services/payment/payment_simulator.dart';
import '../../../cart/data/repositories/cart_repository.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/orders_repository.dart';
import '../../data/models/checkout_draft.dart';

class CheckoutState {
  final bool isSubmitting;
  final String? errorMessage;
  final OrderModel? completedOrder;
  final bool paymentFailed;

  const CheckoutState({
    this.isSubmitting = false,
    this.errorMessage,
    this.completedOrder,
    this.paymentFailed = false,
  });
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final OrdersRepository _ordersRepository;
  final PaymentSimulator _paymentSimulator;
  final CartRepository _cartRepository;

  CheckoutCubit(
    this._ordersRepository,
    this._paymentSimulator,
    this._cartRepository,
  )
      : super(const CheckoutState());

  Future<bool> submit({
    required CheckoutDraft draft,
    required String paymentMethod,
    bool? simulatedSuccess,
  }) async {
    emit(const CheckoutState(isSubmitting: true));
    try {
      String paymentStatus;
      String? transactionId;
      if (paymentMethod == 'cash_on_delivery') {
        paymentStatus = 'pending_on_delivery';
      } else {
        if (simulatedSuccess == null) {
          emit(const CheckoutState(errorMessage: 'اختر نتيجة محاكاة الدفع.'));
          return false;
        }
        final cartItems = await _cartRepository.getItems();
        if (cartItems.isEmpty) {
          emit(const CheckoutState(errorMessage: 'السلة فارغة. أضف منتجات قبل تأكيد الطلب.'));
          return false;
        }
        final subtotal = cartItems.fold<num>(0, (sum, item) => sum + item.totalPrice);
        final result = await _paymentSimulator.simulate(
          succeed: simulatedSuccess,
          amount: (subtotal + draft.deliveryFee).toDouble(),
          currency: 'EGP',
        );
        if (result.status != PaymentStatus.success) {
          emit(CheckoutState(
            paymentFailed: true,
            errorMessage: result.message ?? 'فشلت عملية الدفع التجريبية.',
          ));
          return false;
        }
        paymentStatus = 'paid_simulated';
        transactionId = result.transactionId;
      }

      final order = await _ordersRepository.createOrderFromCart(
        draft: draft,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
      );
      emit(CheckoutState(completedOrder: order));
      return true;
    } catch (_) {
      emit(const CheckoutState(
        errorMessage: 'تعذر تأكيد الطلب. تأكد من اتصالك وحاول مرة أخرى.',
      ));
      return false;
    }
  }
}
