import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/store_search_filter.dart';

class SearchFilterScreen extends StatefulWidget {
  final StoreSearchFilter initialFilter;
  final double maxPrice;
  final List<String> brands;

  const SearchFilterScreen({
    super.key,
    required this.initialFilter,
    required this.maxPrice,
    required this.brands,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late RangeValues _priceRange;
  late int _selectedRating;
  late Set<String> _selectedBrands;

  @override
  void initState() {
    super.initState();
    final upperLimit = widget.maxPrice < 1 ? 100.0 : widget.maxPrice;
    _priceRange = RangeValues(
      widget.initialFilter.minPrice.clamp(0, upperLimit).toDouble(),
      (widget.initialFilter.maxPrice <= 0
              ? upperLimit
              : widget.initialFilter.maxPrice)
          .clamp(0, upperLimit)
          .toDouble(),
    );
    _selectedRating = widget.initialFilter.minRating;
    _selectedBrands = {...widget.initialFilter.brands};
  }

  @override
  Widget build(BuildContext context) {
    final upperLimit = widget.maxPrice < 1 ? 100.0 : widget.maxPrice;
    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: _reset,
          child: const Text(
            'إعادة تعيين',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: const Text(
          'تصفية وتصنيف',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'إغلاق',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'نطاق السعر',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _PriceLabel(
                              text: '${numberFormat.format(_priceRange.start)} ج.م',
                            ),
                            _PriceLabel(
                              text: '${numberFormat.format(_priceRange.end)} ج.م',
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: upperLimit,
                          divisions: upperLimit.round().clamp(1, 1000).toInt(),
                          activeColor: AppColors.primaryDark,
                          onChanged: (values) =>
                              setState(() => _priceRange = values),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'التقييم',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RatingOption(
                    label: '4+ نجوم',
                    value: 4,
                    selected: _selectedRating,
                    onSelected: _selectRating,
                  ),
                  _RatingOption(
                    label: '3+ نجوم',
                    value: 3,
                    selected: _selectedRating,
                    onSelected: _selectRating,
                  ),
                  _RatingOption(
                    label: 'أي تقييم',
                    value: 0,
                    selected: _selectedRating,
                    onSelected: _selectRating,
                  ),
                  if (widget.brands.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'العلامة التجارية',
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.brands.map((brand) {
                      final selected = _selectedBrands.contains(brand);
                      return CheckboxListTile(
                        value: selected,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryDark,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          brand,
                          style: const TextStyle(
                            color: AppColors.mainText,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selectedBrands.add(brand);
                          } else {
                            _selectedBrands.remove(brand);
                          }
                        }),
                      );
                    }),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    StoreSearchFilter(
                      minPrice: _priceRange.start,
                      maxPrice: _priceRange.end >= upperLimit
                          ? 0
                          : _priceRange.end,
                      minRating: _selectedRating,
                      brands: _selectedBrands,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _selectRating(int rating) => setState(() => _selectedRating = rating);

  void _reset() {
    setState(() {
      _priceRange = RangeValues(0, widget.maxPrice < 1 ? 100 : widget.maxPrice);
      _selectedRating = 0;
      _selectedBrands.clear();
    });
  }
}

class _PriceLabel extends StatelessWidget {
  final String text;

  const _PriceLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RatingOption extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final ValueChanged<int> onSelected;

  const _RatingOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(
      value: value,
      groupValue: selected,
      activeColor: AppColors.primaryDark,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      onChanged: (rating) {
        if (rating != null) onSelected(rating);
      },
    );
  }
}
