import '../../../../core/errors/auth_exception_handler.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.login(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw 'كلمات المرور غير متطابقة.';
    }

    try {
      return await remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (newPassword != confirmNewPassword) {
      throw 'كلمة السر الجديدة وتأكيدها غير متطابقين.';
    }

    try {
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }
}