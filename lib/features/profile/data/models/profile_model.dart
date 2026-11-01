import 'dart:convert';
import 'dart:typed_data';

class ProfileModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoBase64;

  const ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoBase64,
  });

  Uint8List? get photoBytes {
    final encodedPhoto = photoBase64;
    if (encodedPhoto == null || encodedPhoto.isEmpty) return null;
    try {
      return base64Decode(encodedPhoto);
    } on FormatException {
      return null;
    }
  }
}
