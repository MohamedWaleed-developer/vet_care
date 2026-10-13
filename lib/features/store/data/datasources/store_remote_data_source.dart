import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class StoreRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StoreRemoteDataSource(this._firestore, this._auth);

  Stream<List<ProductModel>> watchProducts() {
    return _firestore
        .collection(FirebaseCollections.products)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
            .where((product) => product.isAvailable && product.name.isNotEmpty)
            .toList());
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _firestore
        .collection(FirebaseCollections.categories)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
            .where((category) => category.name.isNotEmpty)
            .toList());
  }

  Stream<ProductModel?> watchProduct(String productId) {
    return _firestore
        .collection(FirebaseCollections.products)
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? ProductModel.fromMap(snapshot.id, snapshot.data()!)
            : null);
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    String? variant,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('User is not signed in');

    final item = _firestore
        .collection(FirebaseCollections.carts)
        .doc(userId)
        .collection('items')
        .doc(variant == null
            ? product.id
            : '${product.id}_${Uri.encodeComponent(variant)}');

    await item.set({
      'productId': product.id,
      'variant': variant,
      'name': product.name,
      'unitPrice': product.price,
      'imageUrl': product.imageUrl,
      'quantity': FieldValue.increment(quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
