import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> collection(
      String path,
      ) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document(
      String path,
      ) {
    return _firestore.doc(path);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String path,
      ) {
    return _firestore.doc(path).get();
  }

  Future<void> setDocument({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) {
    return _firestore.doc(path).set(
      data,
      SetOptions(merge: merge),
    );
  }

  Future<void> updateDocument({
    required String path,
    required Map<String, dynamic> data,
  }) {
    return _firestore.doc(path).update(data);
  }

  Future<void> deleteDocument(String path) {
    return _firestore.doc(path).delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(
      String path,
      ) {
    return _firestore.doc(path).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
      String collectionPath,
      ) {
    return _firestore.collection(collectionPath).snapshots();
  }
}