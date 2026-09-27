import '../../data/models/user_model.dart';


abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);
}

class AuthUnauthenticated extends AuthState {}

class PasswordResetEmailSent extends AuthState {
  final String email;

  PasswordResetEmailSent(this.email);
}

class PasswordChangedSuccess extends AuthState {
  final String message;

  PasswordChangedSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}