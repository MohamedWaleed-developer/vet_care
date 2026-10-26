
import 'package:flutter/material.dart';

import '../cubit/admin_orders_state.dart';

class AdminOrdersFilters extends StatelessWidget {
  final AdminOrdersFilter selectedFilter;
  final ValueChanged<AdminOrdersFilter> onChanged;

  const AdminOrdersFilters({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  static const _filters = [
    _FilterData(
      filter: AdminOrdersFilter.all,
      label: 'الكل',
      icon: Icons.list_alt_outlined,
    ),
    _FilterData(
      filter: AdminOrdersFilter.newOrders,
      label: 'جديدة',
      icon: Icons.fiber_new_outlined,
    ),
    _FilterData(
      filter: AdminOrdersFilter.active,
      label: 'نشطة',
      icon: Icons.local_shipping_outlined,
    ),
    _FilterData(
      filter: AdminOrdersFilter.completed,
      label: 'مكتملة',
      icon: Icons.check_circle_outline,
    ),
    _FilterData(
      filter: AdminOrdersFilter.cancelled,
      label: 'ملغاة',
      icon: Icons.cancel_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((item) {
          final isSelected = selectedFilter == item.filter;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              selected: isSelected,
              onSelected: (_) => onChanged(item.filter),
              avatar: Icon(
                item.icon,
                size: 17,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
              label: Text(item.label),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF475569),
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: const Color(0xFF2E7D6B),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF2E7D6B)
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterData {
  final AdminOrdersFilter filter;
  final String label;
  final IconData icon;

  const _FilterData({
    required this.filter,
    required this.label,
    required this.icon,
  });
}
