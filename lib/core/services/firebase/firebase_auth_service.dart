import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> updateDisplayName(String name) {
    return _auth.currentUser?.updateDisplayName(name) ??
        Future.value();
  }

  Future<void> updatePhotoUrl(String photoUrl) {
    return _auth.currentUser?.updatePhotoURL(photoUrl) ??
        Future.value();
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}