
import 'package:flutter/material.dart';

import '../cubit/admin_orders_state.dart';

class AdminOrdersStats extends StatelessWidget {
  final AdminOrdersState state;

  const AdminOrdersStats({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        title: 'إجمالي الطلبات',
        value: state.totalOrders,
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF2E7D6B),
        background: const Color(0xFFE8F5F1),
      ),
      _StatData(
        title: 'طلبات جديدة',
        value: state.newOrdersCount,
        icon: Icons.fiber_new_outlined,
        color: const Color(0xFF3B82A0),
        background: const Color(0xFFEAF4F9),
      ),
      _StatData(
        title: 'طلبات مكتملة',
        value: state.completedOrdersCount,
        icon: Icons.check_circle_outline,
        color: const Color(0xFF16835D),
        background: const Color(0xFFE8F7EF),
      ),
      _StatData(
        title: 'طلبات ملغاة',
        value: state.cancelledOrdersCount,
        icon: Icons.cancel_outlined,
        color: const Color(0xFFD9534F),
        background: const Color(0xFFFCEDEC),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            return _StatCard(data: stats[index]);
          },
        );
      },
    );
  }
}

class _StatData {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EEEB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183C34),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
