import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../models/cart_item_model.dart';

class CartRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRemoteDataSource(this._firestore, this._auth);

  Stream<List<CartItemModel>> watchItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error(StateError('User is not signed in'));
    }

    return _itemsCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final userId = _requireUserId();
    final item = _itemsCollection(userId).doc(itemId);
    if (quantity <= 0) {
      await item.delete();
      return;
    }

    await item.update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItem(String itemId) async {
    final userId = _requireUserId();
    await _itemsCollection(userId).doc(itemId).delete();
  }

  Future<void> clearItems() async {
    final userId = _requireUserId();
    final snapshot = await _itemsCollection(userId).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _itemsCollection(String userId) {
    return _firestore
        .collection(FirebaseCollections.carts)
        .doc(userId)
        .collection('items');
  }

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('User is not signed in');
    return userId;
  }
}
