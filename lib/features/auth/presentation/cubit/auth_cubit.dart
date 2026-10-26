
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  Future<bool> _isCurrentUserAdmin() async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      debugPrint('[AUTH DEBUG] No current Firebase user');
      return false;
    }

    debugPrint('[AUTH DEBUG] Checking admin claims');

    final tokenResult = await user.getIdTokenResult(true);
    final isAdmin = tokenResult.claims?['admin'] == true;

    debugPrint('[AUTH DEBUG] Admin claim result: $isAdmin');

    return isAdmin;
  }

  Future<void> checkCurrentUser() async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final isAdmin = await _isCurrentUserAdmin();

      emit(
        AuthSuccess(
          UserModel.fromFirebaseUser(user),
          isAdmin: isAdmin,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Current user check failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        AuthError('تعذر التحقق من صلاحيات الحساب. حاول مرة أخرى.'),
      );
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      debugPrint('[AUTH DEBUG] Starting login');

      final user = await repository.login(
        email: email,
        password: password,
      );

      debugPrint('[AUTH DEBUG] Login succeeded: ${user.email}');
      debugPrint('[AUTH DEBUG] Starting admin check');

      final isAdmin = await _isCurrentUserAdmin();

      debugPrint('[AUTH DEBUG] Admin check completed: $isAdmin');

      emit(AuthSuccess(user, isAdmin: isAdmin));

      debugPrint('[AUTH DEBUG] AuthSuccess emitted');
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Login flow failed: $e');
      debugPrintStack(stackTrace: stackTrace);

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
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Sign-up failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());

    try {
      await repository.sendPasswordResetEmail(email: email);
      emit(PasswordResetEmailSent(email));
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Password reset failed: $e');
      debugPrintStack(stackTrace: stackTrace);

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
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Password update failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await repository.logout();
      emit(AuthUnauthenticated());
    } catch (e, stackTrace) {
      debugPrint('[AUTH DEBUG] Logout failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(AuthError(e.toString()));
    }
  }
}
