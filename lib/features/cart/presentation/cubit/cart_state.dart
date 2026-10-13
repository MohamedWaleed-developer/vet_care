import '../../data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> pendingItemIds;
  final bool isClearing;

  const CartState({
    this.items = const [],
    this.isLoading = true,
    this.errorMessage,
    this.pendingItemIds = const {},
    this.isClearing = false,
  });

  num get subtotal => items.fold<num>(0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? errorMessage,
    Set<String>? pendingItemIds,
    bool? isClearing,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingItemIds: pendingItemIds ?? this.pendingItemIds,
      isClearing: isClearing ?? this.isClearing,
    );
  }
}
