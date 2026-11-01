import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/services/firebase/firestore_service.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  ProfileRemoteDataSource(this._auth, this._firestoreService);

  Future<ProfileModel> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('لا يوجد مستخدم مسجل الدخول.');

    final snapshot = await _firestoreService.getDocument(_profilePath(user.uid));
    final data = snapshot.data() ?? const <String, dynamic>{};
    final authName = user.displayName?.trim() ?? '';

    return ProfileModel(
      userId: user.uid,
      name: authName.isEmpty ? _stringValue(data['name']) : authName,
      email: user.email ?? '',
      phoneNumber: _stringValue(data['phoneNumber']),
      photoBase64: _stringValue(data['photoBase64']).isEmpty
          ? null
          : _stringValue(data['photoBase64']),
    );
  }

  Future<ProfileModel> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? photoBase64,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('لا يوجد مستخدم مسجل الدخول.');

    final cleanName = name.trim();
    final cleanEmail = email.trim();
    if (cleanName.isEmpty) throw ArgumentError('اكتب الاسم الكامل.');

    final emailVerificationSent =
        cleanEmail.isNotEmpty && cleanEmail != user.email;
    if (emailVerificationSent) {
      await user.verifyBeforeUpdateEmail(cleanEmail);
    }
    if (user.displayName != cleanName) {
      await user.updateDisplayName(cleanName);
    }

    final profileData = <String, dynamic>{
      'uid': user.uid,
      'name': cleanName,
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (photoBase64 != null) profileData['photoBase64'] = photoBase64;

    await _firestoreService.setDocument(
      path: _profilePath(user.uid),
      data: profileData,
      merge: true,
    );
    await user.reload();

    final updatedUser = _auth.currentUser!;
    return ProfileModel(
      userId: updatedUser.uid,
      name: updatedUser.displayName ?? cleanName,
      email: updatedUser.email ?? user.email ?? '',
      phoneNumber: phoneNumber.trim(),
      photoBase64: photoBase64,
    );
  }

  String _profilePath(String userId) =>
      '${FirebaseCollections.users}/$userId';

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

}
