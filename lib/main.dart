import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_view.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencies();

  final notificationService = sl<NotificationService>();

  await notificationService.initialize();

  final token = await notificationService.getToken();

  debugPrint('FCM TOKEN: $token');

  runApp(const VetCareApp());
}

class VetCareApp extends StatelessWidget {
  const VetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Vet Care',
          theme: AppTheme.lightTheme,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: widget ?? const SizedBox.shrink(),
            );
          },
          home: SignUpScreen(),
        );
      },
    );
  }
}