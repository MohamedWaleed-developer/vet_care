import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final profile = await _repository.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (error) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: _errorMessage(error),
      ));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String originalEmail,
    Uint8List? photoBytes,
  }) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true));
    try {
      if (photoBytes != null && photoBytes.length > 512 * 1024) {
        throw ArgumentError('اختاري صورة حجمها أقل من 500 كيلوبايت.');
      }
      final profile = await _repository.updateProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        photoBase64: photoBytes == null
            ? state.profile?.photoBase64
            : _encodePhoto(photoBytes),
      );
      emit(state.copyWith(
        status: ProfileStatus.saved,
        profile: profile,
        emailVerificationSent: email.trim() != originalEmail,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: _errorMessage(error),
      ));
    }
  }

  String _encodePhoto(Uint8List bytes) {
    return base64Encode(bytes);
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'requires-recent-login' =>
          'سجّل الدخول مرة أخرى لتغيير البريد الإلكتروني.',
        'invalid-email' => 'البريد الإلكتروني غير صالح.',
        'email-already-in-use' => 'هذا البريد الإلكتروني مستخدم بالفعل.',
        'network-request-failed' => 'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
        _ => error.message ?? 'تعذر تحديث الملف الشخصي.',
      };
    }
    if (error is StateError) return error.message.toString();
    if (error is ArgumentError) return error.message?.toString() ?? 'تحقق من البيانات المدخلة.';
    return 'تعذر حفظ التغييرات. تحقق من اتصالك وحاول مرة أخرى.';
  }
}
