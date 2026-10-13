import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? name;

  UserModel({
    required this.uid,
    this.email,
    this.name,
  });

  factory UserModel.fromFirebaseUser(User user, {String? name}) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: name ?? user.displayName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }
}
