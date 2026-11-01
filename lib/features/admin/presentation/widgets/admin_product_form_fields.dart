import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../store/data/models/category_model.dart';

class AdminProductFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController previousPriceController;
  final TextEditingController brandController;
  final TextEditingController imageUrlController;
  final TextEditingController imageUrlsController;
  final TextEditingController ingredientsController;
  final TextEditingController variantsController;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final bool isAvailable;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onAvailabilityChanged;

  const AdminProductFormFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.previousPriceController,
    required this.brandController,
    required this.imageUrlController,
    required this.imageUrlsController,
    required this.ingredientsController,
    required this.variantsController,
    required this.categories,
    required this.selectedCategoryId,
    required this.isAvailable,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _field(
            controller: nameController,
            label: 'اسم المنتج',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم المنتج مطلوب';
              }
              return null;
            },
          ),
          _field(
            controller: descriptionController,
            label: 'الوصف',
            maxLines: 3,
          ),
          _field(
            controller: priceController,
            label: 'السعر (ر.س)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final parsed = num.tryParse((value ?? '').trim());
              if (parsed == null) return 'أدخل سعراً صالحاً';
              if (parsed < 0) return 'السعر لا يمكن أن يكون سالباً';
              return null;
            },
          ),
          _field(
            controller: previousPriceController,
            label: 'السعر السابق (اختياري)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return null;
              final parsed = num.tryParse(text);
              if (parsed == null) return 'أدخل سعراً صالحاً';
              if (parsed < 0) return 'السعر لا يمكن أن يكون سالباً';
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedCategoryId),
            initialValue:
                categories.any((category) => category.id == selectedCategoryId)
                ? selectedCategoryId
                : null,
            decoration: _decoration('القسم'),
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: onCategoryChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اختر قسماً';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(controller: brandController, label: 'العلامة التجارية'),
          _field(
            controller: imageUrlController,
            label: 'رابط الصورة الرئيسية',
            validator: _optionalUrlValidator,
          ),
          _field(
            controller: imageUrlsController,
            label: 'روابط صور إضافية (سطر لكل رابط)',
            maxLines: 3,
            validator: (value) {
              final lines = (value ?? '')
                  .split(RegExp(r'[\n,]'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty);
              for (final url in lines) {
                final error = _optionalUrlValidator(url);
                if (error != null) return error;
              }
              return null;
            },
          ),
          _field(
            controller: ingredientsController,
            label: 'المكونات',
            maxLines: 2,
          ),
          _field(
            controller: variantsController,
            label: 'المتغيرات (مفصولة بفاصلة)',
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('المنتج متاح للعملاء'),
            value: isAvailable,
            activeThumbColor: AppColors.primary,
            onChanged: onAvailabilityChanged,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _decoration(label),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  String? _optionalUrlValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'أدخل رابط صورة صالح يبدأ بـ http أو https';
    }
    return null;
  }
}
