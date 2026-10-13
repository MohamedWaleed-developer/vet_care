import 'package:cloud_firestore/cloud_firestore.dart';

class OrderLineItem {
  final String productId;
  final String? variant;
  final String name;
  final String imageUrl;
  final num unitPrice;
  final int quantity;

  const OrderLineItem({
    required this.productId,
    required this.variant,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  num get totalPrice => unitPrice * quantity;

  factory OrderLineItem.fromMap(Map<String, dynamic> data) {
    final price = data['unitPrice'] ?? data['price'];
    final quantity = data['quantity'];
    return OrderLineItem(
      productId: data['productId']?.toString() ?? '',
      variant: data['variant']?.toString(),
      name: data['name']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      unitPrice: price is num ? price : num.tryParse('$price') ?? 0,
      quantity: quantity is num ? quantity.toInt() : int.tryParse('$quantity') ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'variant': variant,
        'name': name,
        'imageUrl': imageUrl,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String shippingMethod;
  final String customerName;
  final String phoneNumber;
  final String city;
  final String address;
  final String deliveryNotes;
  final List<OrderLineItem> items;
  final num subtotal;
  final num deliveryFee;
  final num total;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.customerName,
    required this.phoneNumber,
    required this.city,
    required this.address,
    required this.deliveryNotes,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
  });

  String get itemsDescription {
    if (items.isEmpty) return 'لا توجد منتجات';
    if (items.length == 1) return items.first.name;
    return '${items.first.name} + ${items.length - 1} منتجات أخرى';
  }

  String get statusLabel => switch (status) {
        'confirmed' => 'تم التأكيد',
        'preparing' => 'جاري التجهيز',
        'shipping' => 'قيد التوصيل',
        'delivered' => 'مكتمل',
        'cancelled' => 'ملغي',
        'payment_failed' => 'الدفع لم يكتمل',
        _ => 'قيد المراجعة',
      };

  bool get isCompleted => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => !isCompleted && !isCancelled;

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    final rawItems = data['items'];
    final addressData = data['shippingAddress'];
    final rawCreatedAt = data['createdAt'];

    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) createdAt = rawCreatedAt.toDate();
    if (rawCreatedAt is DateTime) createdAt = rawCreatedAt;

    return OrderModel(
      id: id,
      orderNumber: data['orderNumber']?.toString() ?? id,
      userId: data['userId']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      paymentStatus: data['paymentStatus']?.toString() ?? 'pending',
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      shippingMethod: data['shippingMethod']?.toString() ?? 'standard',
      customerName: addressData is Map
          ? addressData['customerName']?.toString() ?? ''
          : '',
      phoneNumber: addressData is Map
          ? addressData['phoneNumber']?.toString() ?? ''
          : '',
      city: addressData is Map ? addressData['city']?.toString() ?? '' : '',
      address:
          addressData is Map ? addressData['address']?.toString() ?? '' : '',
      deliveryNotes: addressData is Map
          ? addressData['deliveryNotes']?.toString() ?? ''
          : '',
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((item) => OrderLineItem.fromMap(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      subtotal: _number(data['subtotal']),
      deliveryFee: _number(data['deliveryFee']),
      total: _number(data['total']),
      createdAt: createdAt,
    );
  }

  static num _number(dynamic value) =>
      value is num ? value : num.tryParse('$value') ?? 0;
}
