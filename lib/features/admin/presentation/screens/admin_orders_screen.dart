
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/admin_orders_cubit.dart';
import '../cubit/admin_orders_state.dart';
import '../widgets/admin_order_card.dart';
import '../widgets/admin_orders_stats.dart';
import '../widgets/admin_orders_filters.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8F7),
        appBar: AppBar(
          title: const Text(
            'إدارة الطلبات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F5C4F),
          elevation: 0,
          centerTitle: false,
        ),
        body: BlocConsumer<AdminOrdersCubit, AdminOrdersState>(
          listener: (context, state) {
            final message = state.successMessage ?? state.errorMessage;

            if (message != null && message.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: state.errorMessage != null
                        ? Colors.red.shade700
                        : const Color(0xFF1F5C4F),
                  ),
                );

              context.read<AdminOrdersCubit>().clearMessages();
            }
          },
          builder: (context, state) {
            if (!state.accessChecked ||
                state.status == AdminOrdersStatus.initial ||
                (state.status == AdminOrdersStatus.loading &&
                    state.orders.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D6B),
                ),
              );
            }

            if (!state.isAdmin) {
              return _AccessDenied(
                message: state.errorMessage ??
                    'ليس لديك صلاحية الوصول إلى هذه الصفحة.',
              );
            }

            return _OrdersContent(state: state);
          },
        ),
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  final AdminOrdersState state;

  const _OrdersContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminOrdersCubit>();
    final orders = state.filteredOrders;

    return RefreshIndicator(
      onRefresh: () => cubit.start(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'نظرة عامة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183C34),
            ),
          ),
          const SizedBox(height: 14),
          AdminOrdersStats(state: state),
          const SizedBox(height: 24),
          TextField(
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث برقم الطلب أو اسم العميل أو الهاتف',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AdminOrdersFilters(
            selectedFilter: state.filter,
            onChanged: cubit.changeFilter,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'الطلبات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183C34),
                  ),
                ),
              ),
              Text(
                '${orders.length} طلب',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.status == AdminOrdersStatus.failure &&
              state.orders.isEmpty)
            _EmptyOrders(
              icon: Icons.cloud_off_outlined,
              title: 'تعذر تحميل الطلبات',
              subtitle: state.errorMessage ?? 'حاول مرة أخرى.',
              actionLabel: 'إعادة المحاولة',
              onAction: cubit.start,
            )
          else if (orders.isEmpty)
            const _EmptyOrders(
              icon: Icons.receipt_long_outlined,
              title: 'لا توجد طلبات',
              subtitle: 'لا توجد طلبات تطابق البحث أو الفلتر المحدد.',
            )
          else
            ...orders.map(
                  (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminOrderCard(order: order),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final String message;

  const _AccessDenied({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 56,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            const Text(
              'غير مسموح بالدخول',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _EmptyOrders({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 52, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183C34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
