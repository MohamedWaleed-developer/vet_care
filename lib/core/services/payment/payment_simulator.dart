import 'dart:math';

import 'payment_result.dart';
import 'payment_service.dart';

class PaymentSimulator implements PaymentService {
  final Random _random;

  PaymentSimulator({Random? random}) : _random = random ?? Random();

  Future<PaymentResult> simulate({
    required bool succeed,
    required double amount,
    required String currency,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!succeed) {
      return const PaymentResult(
        status: PaymentStatus.failed,
        message: 'محاكاة تجريبية: عملية الدفع لم تنجح.',
      );
    }
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: 'SIM-${_random.nextInt(0xFFFFFF).toRadixString(16).toUpperCase()}',
      message: 'تمت محاكاة نجاح الدفع. لم يتم خصم أي مبلغ.',
    );
  }

  @override
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async => const PaymentResult(
        status: PaymentStatus.pending,
        message: 'بوابة الدفع الحقيقية غير مفعلة.',
      );
}
