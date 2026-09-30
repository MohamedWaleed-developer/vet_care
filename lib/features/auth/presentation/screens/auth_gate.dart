feature/auth



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_screen.dart';
import 'login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/auth_injection.dart';
import 'auth_view.dart';
 development

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
 feature/auth
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

*/







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
 development
