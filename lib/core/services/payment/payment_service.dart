import 'payment_result.dart';

abstract class PaymentService {
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String currency,
  });
}