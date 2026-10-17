import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';

class AdminRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRemoteDataSource(this._firestore, this._auth);

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }

  void _ensureSignedIn() {
    if (_auth.currentUser == null) {
      throw StateError('يجب تسجيل الدخول أولاً.');
    }
  }

  Future<void> _ensureAdmin() async {
    _ensureSignedIn();
    if (!await isAdmin()) {
      throw StateError('ليس لديك صلاحية الإدارة.');
    }
  }

  Stream<List<ProductModel>> watchAllProducts() {
    return _firestore
        .collection(FirebaseCollections.products)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .where((product) => product.name.isNotEmpty)
              .toList(),
        );
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _firestore
        .collection(FirebaseCollections.categories)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .where((category) => category.name.isNotEmpty)
              .toList(),
        );
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required num price,
    required String categoryId,
    required String brand,
    required String imageUrl,
    required List<String> imageUrls,
    required String ingredients,
    required List<String> variants,
    num? previousPrice,
    bool isAvailable = true,
  }) async {
    await _ensureAdmin();

    final images = _normalizeImages(imageUrl, imageUrls);
    await _firestore.collection(FirebaseCollections.products).add({
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
      'rating': 0,
      'reviewsCount': 0,
      'imageUrl': images.isEmpty ? '' : images.first,
      'imageUrls': images,
      'categoryId': categoryId.trim(),
      'brand': brand.trim(),
      'isAvailable': isAvailable,
      'isActive': isAvailable,
      'previousPrice': previousPrice,
      'ingredients': ingredients.trim(),
      'variants': variants,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required ProductModel existing,
    required String name,
    required String description,
    required num price,
    required String categoryId,
    required String brand,
    required String imageUrl,
    required List<String> imageUrls,
    required String ingredients,
    required List<String> variants,
    num? previousPrice,
    required bool isAvailable,
  }) async {
    await _ensureAdmin();

    final images = _normalizeImages(imageUrl, imageUrls);
    await _firestore
        .collection(FirebaseCollections.products)
        .doc(existing.id)
        .update({
          'name': name.trim(),
          'description': description.trim(),
          'price': price,
          'rating': existing.rating,
          'reviewsCount': existing.reviewsCount,
          'imageUrl': images.isEmpty ? '' : images.first,
          'imageUrls': images,
          'categoryId': categoryId.trim(),
          'brand': brand.trim(),
          'isAvailable': isAvailable,
          'isActive': isAvailable,
          'previousPrice': previousPrice,
          'ingredients': ingredients.trim(),
          'variants': variants,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> setProductAvailability({
    required String productId,
    required bool isAvailable,
  }) async {
    await _ensureAdmin();
    await _firestore
        .collection(FirebaseCollections.products)
        .doc(productId)
        .update({
          'isAvailable': isAvailable,
          'isActive': isAvailable,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteProduct(String productId) async {
    await _ensureAdmin();
    await _firestore
        .collection(FirebaseCollections.products)
        .doc(productId)
        .delete();
  }

  List<String> _normalizeImages(String imageUrl, List<String> imageUrls) {
    final urls = <String>[];
    for (final url in imageUrls) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty && !urls.contains(trimmed)) urls.add(trimmed);
    }
    final primary = imageUrl.trim();
    if (primary.isNotEmpty && !urls.contains(primary)) {
      urls.insert(0, primary);
    }
    return urls;
  }
}
