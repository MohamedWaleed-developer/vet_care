import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final FirebaseAuth firebaseAuth;

  AuthCubit(this.repository, this.firebaseAuth) : super(AuthInitial());

  void checkCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthSuccess(UserModel.fromFirebaseUser(user)));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final user = await repository.login(
        email: email,
        password: password,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());

    try {
      final user = await repository.signUp(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());

    try {
      await repository.sendPasswordResetEmail(email: email);
      emit(PasswordResetEmailSent(email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    emit(AuthLoading());

    try {
      await repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      emit(PasswordChangedSuccess('تم تغيير كلمة المرور بنجاح'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await repository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}