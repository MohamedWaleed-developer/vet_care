
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orders/data/models/order_model.dart';
import '../cubit/admin_orders_cubit.dart';
import '../cubit/admin_orders_state.dart';

class AdminOrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const AdminOrderDetailsDialog({
    super.key,
    required this.order,
  });

  static const _statuses = [
    ('confirmed', 'تم التأكيد'),
    ('preparing', 'جاري التجهيز'),
    ('shipping', 'قيد التوصيل'),
    ('delivered', 'مكتمل'),
    ('cancelled', 'ملغي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
            builder: (context, state) {
              final updating =
                  state.status == AdminOrdersStatus.updating;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'تفاصيل الطلب',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF183C34),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'رقم الطلب: ${order.orderNumber.isEmpty ? order.id : order.orderNumber}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'بيانات العميل'),
                    _DetailRow(
                      label: 'الاسم',
                      value: _value(order.customerName),
                    ),
                    _DetailRow(
                      label: 'رقم الهاتف',
                      value: _value(order.phoneNumber),
                    ),
                    _DetailRow(
                      label: 'المدينة',
                      value: _value(order.city),
                    ),
                    _DetailRow(
                      label: 'العنوان',
                      value: _value(order.address),
                    ),
                    if (order.deliveryNotes.trim().isNotEmpty)
                      _DetailRow(
                        label: 'ملاحظات التوصيل',
                        value: order.deliveryNotes,
                      ),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'المنتجات'),
                    if (order.items.isEmpty)
                      const Text(
                        'لا توجد تفاصيل للمنتجات في هذا الطلب.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      )
                    else
                      ...order.items.map(
                            (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.variant != null &&
                                        item.variant!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.variant!,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 5),
                                    Text(
                                      '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} ر.س',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${item.totalPrice.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F5C4F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _SectionTitle(title: 'ملخص المبلغ'),
                    _DetailRow(
                      label: 'قيمة المنتجات',
                      value: '${order.subtotal.toStringAsFixed(2)} ر.س',
                    ),
                    _DetailRow(
                      label: 'رسوم التوصيل',
                      value: '${order.deliveryFee.toStringAsFixed(2)} ر.س',
                    ),
                    const Divider(height: 22),
                    _DetailRow(
                      label: 'الإجمالي',
                      value: '${order.total.toStringAsFixed(2)} ر.س',
                      bold: true,
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'الدفع والتوصيل'),
                    _DetailRow(
                      label: 'طريقة الدفع',
                      value: _paymentMethod(order.paymentMethod),
                    ),
                    _DetailRow(
                      label: 'حالة الدفع',
                      value: _paymentStatus(order.paymentStatus),
                    ),
                    _DetailRow(
                      label: 'طريقة التوصيل',
                      value: _shippingMethod(order.shippingMethod),
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle(title: 'تحديث حالة الطلب'),
                    DropdownButtonFormField<String>(
                      initialValue: _statuses.any(
                            (entry) => entry.$1 == order.status,
                      )
                          ? order.status
                          : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F8F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text('اختر الحالة الجديدة'),
                      items: _statuses
                          .map(
                            (entry) => DropdownMenuItem<String>(
                          value: entry.$1,
                          child: Text(entry.$2),
                        ),
                      )
                          .toList(),
                      onChanged: updating
                          ? null
                          : (status) async {
                        if (status == null ||
                            status == order.status) {
                          return;
                        }

                        final confirmed = await _confirmStatusChange(
                          context,
                          status,
                        );

                        if (!confirmed || !context.mounted) return;

                        final success = await context
                            .read<AdminOrdersCubit>()
                            .updateStatus(
                          orderId: order.id,
                          status: status,
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    if (updating) ...[
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(
                        color: Color(0xFF2E7D6B),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmStatusChange(
      BuildContext context,
      String status,
      ) async {
    final label = _statuses
        .where((entry) => entry.$1 == status)
        .map((entry) => entry.$2)
        .firstOrNull;

    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد تحديث الطلب'),
        content: Text(
          'هل تريد تغيير حالة الطلب إلى "${label ?? status}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D6B),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ) ??
        false;
  }

  static String _value(String value) {
    return value.trim().isEmpty ? 'غير متوفر' : value;
  }

  static String _paymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
      case 'cod':
      case 'cash_on_delivery':
        return 'الدفع عند الاستلام';
      case 'card':
        return 'بطاقة بنكية';
      case 'mada':
        return 'مدى';
      case 'apple_pay':
        return 'Apple Pay';
      default:
        return _value(method);
    }
  }

  static String _paymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'succeeded':
        return 'مدفوع';
      case 'pending':
        return 'قيد الانتظار';
      case 'failed':
      case 'payment_failed':
        return 'فشل الدفع';
      case 'refunded':
        return 'تم استرداد المبلغ';
      default:
        return _value(status);
    }
  }

  static String _shippingMethod(String method) {
    switch (method.toLowerCase()) {
      case 'delivery':
      case 'standard':
      case 'home_delivery':
        return 'توصيل للعنوان';
      case 'pickup':
      case 'store_pickup':
        return 'استلام من الفرع';
      default:
        return _value(method);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F5C4F),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: bold
                    ? const Color(0xFF1F5C4F)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
