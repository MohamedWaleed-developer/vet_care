import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../data/models/order_model.dart';
import '../cubit/orders_cubit.dart';

String _money(num amount) => NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 0,
    ).format(amount);

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: BlocProvider(
          create: (_) => sl<OrdersCubit>(),
          child: _OrderDetailsView(order: order),
        ),
      );
}

class _OrderDetailsView extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsView({required this.order});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('تفاصيل الطلب'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.orderNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(order.createdAt == null ? 'تاريخ الطلب غير متاح' : 'تاريخ الطلب: ${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'),
                const SizedBox(height: 10),
                Text('الحالة: ${order.statusLabel}', style: const TextStyle(color: Color(0xFF1E6554), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_paymentLabel(order.paymentStatus)),
              ]),
            ),
            const SizedBox(height: 12),
            _section(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('المنتجات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(children: [
                        Expanded(child: Text('${item.name} × ${item.quantity}')),
                        Text(_money(item.totalPrice)),
                      ]),
                    )),
              ]),
            ),
            const SizedBox(height: 12),
            _section(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('عنوان التوصيل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(order.customerName),
                Text(order.phoneNumber),
                Text('${order.city}، ${order.address}'),
                if (order.deliveryNotes.isNotEmpty) Text('ملاحظات: ${order.deliveryNotes}'),
              ]),
            ),
            const SizedBox(height: 12),
            _section(
              child: Column(children: [
                _row('المجموع الفرعي', _money(order.subtotal)),
                const SizedBox(height: 8),
                _row('التوصيل', _money(order.deliveryFee)),
                const Divider(height: 24),
                _row('الإجمالي', _money(order.total), bold: true),
              ]),
            ),
            if (order.isCompleted || order.isCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await context.read<OrdersCubit>().reorder(order);
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, RouteNames.cart);
                    } catch (_) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إضافة المنتجات للسلة. حاول مرة أخرى.')));
                    }
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('اطلب المنتجات مرة أخرى'),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _section({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      );

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))],
      );

  String _paymentLabel(String status) => switch (status) {
        'paid_simulated' => 'الدفع الإلكتروني: نجاح تجريبي بدون خصم',
        'pending_on_delivery' => 'الدفع: عند الاستلام',
        _ => 'حالة الدفع: $status',
      };
}
