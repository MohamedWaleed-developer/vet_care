
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
          home: BlocProvider(
            create: (_) => getIt<AuthCubit>()..checkCurrentUser(),
            child: SplashScreen(),
          ),
        );
      },
    );
  }
}