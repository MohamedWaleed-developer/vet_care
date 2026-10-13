import 'package:flutter/material.dart';

class MonthYearPicker extends StatelessWidget {
  final String title;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const MonthYearPicker({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  static const List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    final years = List.generate(
      30,
          (index) => currentYear - index,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: _Dropdown<int>(
                hint: 'الشهر',
                value: value?.month,
                items: List.generate(
                  12,
                      (index) => index + 1,
                ),
                itemLabel: (month) => months[month - 1],
                onChanged: (month) {
                  if (month == null) {
                    return;
                  }

                  final year = value?.year ?? currentYear;

                  onChanged(
                    DateTime(
                      year,
                      month,
                      1,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _Dropdown<int>(
                hint: 'السنة',
                value: value?.year,
                items: years,
                itemLabel: (year) => year.toString(),
                onChanged: (year) {
                  if (year == null) {
                    return;
                  }

                  final month = value?.month ?? 1;

                  onChanged(
                    DateTime(
                      year,
                      month,
                      1,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6E4DC),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF4A5568),
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF4A5568),
          ),
          items: items.map(
                (item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}