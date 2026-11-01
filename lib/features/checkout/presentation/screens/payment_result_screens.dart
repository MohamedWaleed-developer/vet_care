import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../orders/data/models/order_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const PaymentSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 48, backgroundColor: Color(0xFFE6F3EF), child: Icon(Icons.check_circle, size: 58, color: Color(0xFF1E6554))),
                  const SizedBox(height: 24),
                  const Text('تم تأكيد طلبك', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('رقم الطلب ${order.orderNumber}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    order.paymentStatus == 'paid_simulated'
                        ? 'نجحت محاكاة الدفع التجريبية. لم يتم خصم أي مبلغ.'
                        : 'طلبك مسجل للدفع عند الاستلام.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.orderDetails, arguments: order),
                      child: const Text('تفاصيل الطلب'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, RouteNames.orders, (route) => route.settings.name == RouteNames.home),
                    child: const Text('طلباتي'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class PaymentFailedScreen extends StatelessWidget {
  final String? message;

  const PaymentFailedScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 48, backgroundColor: Color(0xFFFFEEEE), child: Icon(Icons.close_rounded, size: 58, color: Colors.red)),
                  const SizedBox(height: 24),
                  const Text('محاكاة الدفع لم تنجح', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(message ?? 'لم يتم إنشاء طلب أو خصم مبلغ، وما زالت منتجاتك في السلة.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('العودة وإعادة المحاولة')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, RouteNames.cart, (route) => route.settings.name == RouteNames.home),
                    child: const Text('العودة إلى السلة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

String formatOrderMoney(num amount) =>
    NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0).format(amount);
