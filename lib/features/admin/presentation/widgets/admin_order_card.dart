
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orders/data/models/order_model.dart';
import '../cubit/admin_orders_cubit.dart';
import '../screens/admin_order_details_dialog.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const AdminOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EEEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF2E7D6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber.isEmpty
                          ? 'طلب ${order.id}'
                          : 'طلب #${order.orderNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF183C34),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: Color(0xFFE7EEEB),
            ),
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: order.customerName.isEmpty
                ? 'العميل غير محدد'
                : order.customerName,
          ),
          const SizedBox(height: 9),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: order.phoneNumber.isEmpty
                ? 'رقم الهاتف غير متوفر'
                : order.phoneNumber,
          ),
          const SizedBox(height: 9),
          _InfoRow(
            icon: Icons.shopping_bag_outlined,
            label: '${order.items.length} منتج',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${order.total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F5C4F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final cubit = context.read<AdminOrdersCubit>();

                showDialog<void>(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: AdminOrderDetailsDialog(order: order),
                  ),
                );
              },
              icon: const Icon(
                Icons.visibility_outlined,
                size: 18,
              ),
              label: const Text('عرض التفاصيل وإدارة الحالة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D6B),
                side: const BorderSide(
                  color: Color(0xFFB9D9CF),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF3B82A0);
      case 'preparing':
        return const Color(0xFFB7791F);
      case 'shipping':
        return const Color(0xFF6D5BD0);
      case 'delivered':
        return const Color(0xFF16835D);
      case 'cancelled':
      case 'payment_failed':
        return const Color(0xFFD9534F);
      default:
        return const Color(0xFF64748B);
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'تاريخ الطلب غير متوفر';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
