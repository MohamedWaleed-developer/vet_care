import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../../../store/data/models/product_model.dart';

class FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesRemoteDataSource(this._firestore, this._auth);

  Stream<List<ProductModel>> watchFavorites() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(const <ProductModel>[]);

    return _favoritesCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((document) {
              final data = document.data();
              final productData = data['product'];
              if (productData is! Map) return null;
              return ProductModel.fromMap(
                document.id,
                Map<String, dynamic>.from(productData),
              );
            }).whereType<ProductModel>().toList());
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('User is not signed in');

    final favorite = _favoritesCollection(userId).doc(product.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(favorite);
      if (snapshot.exists) {
        transaction.delete(favorite);
      } else {
        transaction.set(favorite, {
          'productId': product.id,
          'product': product.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  CollectionReference<Map<String, dynamic>> _favoritesCollection(
    String userId,
  ) =>
      _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.favorites);
}
