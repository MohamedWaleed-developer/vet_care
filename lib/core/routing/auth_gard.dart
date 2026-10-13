import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  final FirebaseAuth _auth;

  AuthGuard(this._auth);

  bool get isAuthenticated {
    return _auth.currentUser != null;
  }
}