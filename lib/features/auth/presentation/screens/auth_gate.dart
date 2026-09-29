import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/auth_injection.dart';
import 'auth_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: getIt<FirebaseAuth>().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // مسجل دخول -> شاشة مؤقتة لحد ما تعمل الهوم
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('الرئيسية')),
            body: Center(
              child: Text('أهلاً ${snapshot.data?.displayName ?? ''}'),
            ),
          );
        }

        // غير مسجل -> شاشة التسجيل
        return const SignUpScreen();
      },
    );
  }
}