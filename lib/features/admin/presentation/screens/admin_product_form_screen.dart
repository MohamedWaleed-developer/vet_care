import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../store/data/models/product_model.dart';
import '../cubit/admin_products_cubit.dart';
import '../cubit/admin_products_state.dart';
import '../widgets/admin_product_form_fields.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _previousPriceController;
  late final TextEditingController _brandController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _imageUrlsController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _variantsController;
  String? _selectedCategoryId;
  late bool _isAvailable;
  var _submitted = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _previousPriceController = TextEditingController(
      text: product?.previousPrice?.toString() ?? '',
    );
    _brandController = TextEditingController(text: product?.brand ?? '');
    _imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    _imageUrlsController = TextEditingController(
      text: _extraImageUrls(product).join('\n'),
    );
    _ingredientsController = TextEditingController(
      text: product?.ingredients ?? '',
    );
    _variantsController = TextEditingController(
      text: product?.variants.join(', ') ?? '',
    );
    _selectedCategoryId = product?.categoryId;
    _isAvailable = product?.isAvailable ?? true;
  }

  List<String> _extraImageUrls(ProductModel? product) {
    if (product == null) return const [];
    return product.imageUrls
        .where((url) => url.isNotEmpty && url != product.imageUrl)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _previousPriceController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    _imageUrlsController.dispose();
    _ingredientsController.dispose();
    _variantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(_isEditing ? 'تعديل المنتج' : 'إضافة منتج')),
        body: BlocConsumer<AdminProductsCubit, AdminProductsState>(
          listenWhen: (previous, current) =>
              previous.successMessage != current.successMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final success = state.successMessage;
            if (success != null && success.isNotEmpty) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            final saving = state.status == AdminProductsStatus.saving;
            return AbsorbPointer(
              absorbing: saving,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  AdminProductFormFields(
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    previousPriceController: _previousPriceController,
                    brandController: _brandController,
                    imageUrlController: _imageUrlController,
                    imageUrlsController: _imageUrlsController,
                    ingredientsController: _ingredientsController,
                    variantsController: _variantsController,
                    categories: state.categories,
                    selectedCategoryId: _selectedCategoryId,
                    isAvailable: _isAvailable,
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                    onAvailabilityChanged: (value) {
                      setState(() => _isAvailable = value);
                    },
                  ),
                  if (state.categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'لا توجد أقسام حالياً. أضف قسماً أولاً من Firebase ثم أعد المحاولة.',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: saving || _submitted ? null : _submit,
                    child: saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة المنتج'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitted) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitted = true);
    final cubit = context.read<AdminProductsCubit>();
    final extraUrls = _imageUrlsController.text
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final variants = _variantsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final previousText = _previousPriceController.text.trim();
    final previousPrice = previousText.isEmpty
        ? null
        : num.tryParse(previousText);
    final existing = widget.product;
    final ok = existing == null
        ? await cubit.createProduct(
            name: _nameController.text,
            description: _descriptionController.text,
            price: num.parse(_priceController.text.trim()),
            categoryId: _selectedCategoryId ?? '',
            brand: _brandController.text,
            imageUrl: _imageUrlController.text,
            imageUrls: extraUrls,
            ingredients: _ingredientsController.text,
            variants: variants,
            previousPrice: previousPrice,
            isAvailable: _isAvailable,
          )
        : await cubit.updateProduct(
            existing: existing,
            name: _nameController.text,
            description: _descriptionController.text,
            price: num.parse(_priceController.text.trim()),
            categoryId: _selectedCategoryId ?? '',
            brand: _brandController.text,
            imageUrl: _imageUrlController.text,
            imageUrls: extraUrls,
            ingredients: _ingredientsController.text,
            variants: variants,
            previousPrice: previousPrice,
            isAvailable: _isAvailable,
          );

    if (!ok && mounted) setState(() => _submitted = false);
  }
}
