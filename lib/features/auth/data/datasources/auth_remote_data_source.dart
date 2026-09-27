import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource(this.firebaseAuth);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user == null) {
      throw Exception('فشل استرجاع بيانات المستخدم');
    }

    return UserModel.fromFirebaseUser(credential.user!);
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('فشل إنشاء الحساب');
    }

    await user.updateDisplayName(name.trim());
    await user.reload();

    return UserModel.fromFirebaseUser(firebaseAuth.currentUser!, name: name.trim());
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('المستخدم غير مسجل الدخول.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}