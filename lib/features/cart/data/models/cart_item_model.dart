class CartItemModel {
  final String id;
  final String productId;
  final String? variant;
  final String name;
  final num unitPrice;
  final String imageUrl;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.variant,
    required this.name,
    required this.unitPrice,
    required this.imageUrl,
    required this.quantity,
  });

  num get totalPrice => unitPrice * quantity;

  factory CartItemModel.fromMap(String id, Map<String, dynamic> data) {
    final rawPrice = data['unitPrice'] ?? data['price'];
    final rawQuantity = data['quantity'];

    return CartItemModel(
      id: id,
      productId: data['productId']?.toString() ?? id,
      variant: data['variant']?.toString(),
      name: data['name']?.toString() ?? data['title']?.toString() ?? '',
      unitPrice: rawPrice is num ? rawPrice : num.tryParse('$rawPrice') ?? 0,
      imageUrl: data['imageUrl']?.toString() ?? '',
      quantity: rawQuantity is num
          ? rawQuantity.toInt()
          : int.tryParse('$rawQuantity') ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'variant': variant,
        'name': name,
        'unitPrice': unitPrice,
        'imageUrl': imageUrl,
        'quantity': quantity,
      };
}
