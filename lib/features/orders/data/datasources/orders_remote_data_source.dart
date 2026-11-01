import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../checkout/data/models/checkout_draft.dart';
import '../models/order_model.dart';

class OrdersRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrdersRemoteDataSource(this._firestore, this._auth);

  Stream<List<OrderModel>> watchOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error(StateError('User is not signed in'));
    }

    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
      orders.sort((a, b) =>
          (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      return orders;
    });
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final userId = _requireUserId();
    final snapshot = await _ordersCollection.doc(orderId).get();
    if (!snapshot.exists || snapshot.data()?['userId'] != userId) return null;
    return OrderModel.fromMap(snapshot.id, snapshot.data()!);
  }

  Future<OrderModel> createOrderFromCart({
    required CheckoutDraft draft,
    required String paymentMethod,
    required String paymentStatus,
    String? transactionId,
  }) async {
    final userId = _requireUserId();
    final cartItems = _firestore
        .collection(FirebaseCollections.carts)
        .doc(userId)
        .collection('items');
    final cartSnapshot = await cartItems.get();
    if (cartSnapshot.docs.isEmpty) throw StateError('Cart is empty');

    final items = cartSnapshot.docs
        .map((doc) => CartItemModel.fromMap(doc.id, doc.data()))
        .toList();
    final subtotal = items.fold<num>(0, (sum, item) => sum + item.totalPrice);
    final now = DateTime.now();
    final orderReference = _ordersCollection.doc();
    final orderNumber = 'VET-${orderReference.id.substring(0, 8).toUpperCase()}';
    final data = <String, dynamic>{
      'orderNumber': orderNumber,
      'userId': userId,
      'status': 'confirmed',
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'currency': 'EGP',
      'shippingMethod': draft.shippingMethod,
      'shippingAddress': draft.toShippingAddressMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': draft.deliveryFee,
      'total': subtotal + draft.deliveryFee,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.batch();
    batch.set(orderReference, data);
    for (final document in cartSnapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();

    return OrderModel.fromMap(orderReference.id, {
      ...data,
      'createdAt': now,
    });
  }

  Future<void> addOrderItemsToCart(OrderModel order) async {
    final userId = _requireUserId();
    final batch = _firestore.batch();
    final cartItems = _firestore
        .collection(FirebaseCollections.carts)
        .doc(userId)
        .collection('items');

    for (final item in order.items) {
      final itemId = item.variant == null || item.variant!.isEmpty
          ? item.productId
          : '${item.productId}_${Uri.encodeComponent(item.variant!)}';
      batch.set(
        cartItems.doc(itemId),
        {
          'productId': item.productId,
          'variant': item.variant,
          'name': item.name,
          'unitPrice': item.unitPrice,
          'imageUrl': item.imageUrl,
          'quantity': FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    if (order.items.isNotEmpty) await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirebaseCollections.orders);

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('User is not signed in');
    return userId;
  }
}
