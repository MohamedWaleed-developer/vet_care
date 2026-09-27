import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'auth_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // تسجيل FirebaseAuth يدوياً لأنه مكتبة خارجية (third-party)
  // بالـ isRegistered check عشان لو setup_dependencies() اتنفذ قبله
  // ما يحصل تعارض (GetIt بيرمي error لو نفس النوع اتسجل مرتين)
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  // هذا السطر يستدعي كل الـ classes المعلّمة بـ @injectable / @lazySingleton
  // تلقائياً بعد تشغيل build_runner
  await getIt.init();
}

