import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';

enum AdminProductsStatus { initial, loading, ready, saving, failure }

class AdminProductsState {
  final AdminProductsStatus status;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String? errorMessage;
  final String? successMessage;
  final bool isAdmin;
  final bool accessChecked;

  const AdminProductsState({
    this.status = AdminProductsStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.errorMessage,
    this.successMessage,
    this.isAdmin = false,
    this.accessChecked = false,
  });

  AdminProductsState copyWith({
    AdminProductsStatus? status,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isAdmin,
    bool? accessChecked,
  }) {
    return AdminProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      isAdmin: isAdmin ?? this.isAdmin,
      accessChecked: accessChecked ?? this.accessChecked,
    );
  }

  String categoryNameFor(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'بدون قسم';
  }
}
