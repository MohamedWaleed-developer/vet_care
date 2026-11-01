import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../checkout/presentation/screens/payment_result_screens.dart';
import '../../data/models/order_model.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: BlocProvider(create: (_) => sl<OrdersCubit>()..watchOrders(), child: const _OrdersView()),
      );
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('طلباتي'), centerTitle: true),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.isLoading && state.orders.isEmpty) return const Center(child: CircularProgressIndicator());
            if (state.errorMessage != null && state.orders.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(state.errorMessage!), TextButton(onPressed: () => context.read<OrdersCubit>().watchOrders(), child: const Text('إعادة المحاولة'))]));
            }
            final orders = state.orders.where((order) => _matches(order)).toList();
            return Column(
              children: [
                _tabs(state.orders),
                Expanded(
                  child: orders.isEmpty
                      ? const Center(child: Text('لا توجد طلبات في هذا القسم بعد.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                        ),
                ),
              ],
            );
          },
        ),
      );

  Widget _tabs(List<OrderModel> all) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _tabButton('نشطة', all.where((e) => e.isActive).length, 0),
            _tabButton('مكتملة', all.where((e) => e.isCompleted).length, 1),
            _tabButton('ملغاة', all.where((e) => e.isCancelled).length, 2),
          ],
        ),
      );

  Widget _tabButton(String text, int count, int index) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(backgroundColor: _tab == index ? const Color(0xFFE6F3EF) : Colors.white, foregroundColor: const Color(0xFF1E6554)),
            onPressed: () => setState(() => _tab = index),
            child: Text('$text ($count)', maxLines: 1),
          ),
        ),
      );

  bool _matches(OrderModel order) => switch (_tab) {
        1 => order.isCompleted,
        2 => order.isCancelled,
        _ => order.isActive,
      };
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, RouteNames.orderDetails, arguments: order),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)), Text(order.statusLabel, style: const TextStyle(color: Color(0xFF1E6554)))]),
              const SizedBox(height: 10),
              Text(order.itemsDescription, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} منتجات'), Text(formatOrderMoney(order.total), style: const TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 10),
              const Align(alignment: AlignmentDirectional.centerEnd, child: Text('عرض التفاصيل ←', style: TextStyle(color: Color(0xFF1E6554)))),
            ],
          ),
        ),
      );
}
