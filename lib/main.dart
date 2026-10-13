import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/auth_injection.dart';
import 'core/di/injection_container.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'core/routing/route_names.dart';
import 'features/checkout/data/models/checkout_draft.dart';
import 'features/checkout/presentation/screens/checkout_step1_screen.dart';
import 'features/checkout/presentation/screens/payment_result_screens.dart';
import 'features/checkout/presentation/screens/payment_step2_screen.dart';
import 'features/orders/data/models/order_model.dart';
import 'features/orders/presentation/screens/order_details_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/vaccinations/presentation/cubit/vaccinations_cubit.dart';
import 'features/vaccinations/presentation/views/vaccinations_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/store/presentation/screens/product_details_screen.dart';
import 'features/store/presentation/screens/search_screen.dart';
import 'features/store/presentation/screens/store_screen.dart';
import 'features/splash/presentation/views/splash_view.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencies();
  await configureDependencies();

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkCurrentUser(),
        ),
      ],
      child: ScreenUtilInit(
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
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(), // مسار شاشة الهوم الرئيسية
              RouteNames.store: (context) => StoreScreen(
                    initialCategoryId: ModalRoute.of(context)?.settings.arguments as String?,
                  ),
              RouteNames.search: (_) => const SearchScreen(),
              RouteNames.productDetails: (context) => ProductDetailsScreen(
                    productId: (ModalRoute.of(context)?.settings.arguments as String?) ?? '',
                  ),
              RouteNames.cart: (_) => const CartScreen(),
              RouteNames.checkout: (_) => const CheckoutStep1Screen(),
              RouteNames.payment: (context) => PaymentStep2Screen(
                    draft: ModalRoute.of(context)!.settings.arguments! as CheckoutDraft,
                  ),
              RouteNames.paymentSuccess: (context) => PaymentSuccessScreen(
                    order: ModalRoute.of(context)!.settings.arguments! as OrderModel,
                  ),
              RouteNames.paymentFailed: (context) => PaymentFailedScreen(
                    message: ModalRoute.of(context)?.settings.arguments as String?,
                  ),
              RouteNames.orders: (_) => const OrdersScreen(),
              RouteNames.orderDetails: (context) => OrderDetailsScreen(
                    order: ModalRoute.of(context)!.settings.arguments! as OrderModel,
                  ),
              RouteNames.vaccinations: (context) => BlocProvider(
                    create: (_) => sl<VaccinationsCubit>(),
                    child: VaccinationsView(
                      petId: ModalRoute.of(context)!.settings.arguments! as String,
                    ),
                  ),
            },
          );
        },
      ),
    );
  }
}
