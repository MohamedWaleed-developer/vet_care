
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firestore_service.dart';
import '../services/notifications/fcm_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/payment/payment_simulator.dart';

import '../../features/pets/data/datasources/pets_remote_data_source.dart';
import '../../features/pets/data/repositories/pets_repository.dart';
import '../../features/pets/presentation/cubit/pets_cubit.dart';

import '../../features/store/data/datasources/store_remote_data_source.dart';
import '../../features/store/data/repositories/store_repository.dart';
import '../../features/store/presentation/cubit/store_cubit.dart';
import '../../features/store/presentation/cubit/product_details_cubit.dart';
import '../../features/store/presentation/cubit/search_cubit.dart';

import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';

import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';

import '../../features/checkout/presentation/cubit/checkout_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_products_cubit.dart';
import '../../features/admin/presentation/cubit/admin_orders_cubit.dart';

import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
          () => FirebaseFirestore.instance,
    );
  }

  if (!sl.isRegistered<FirebaseMessaging>()) {
    sl.registerLazySingleton<FirebaseMessaging>(
          () => FirebaseMessaging.instance,
    );
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => DioClient().dio);
  }

  if (!sl.isRegistered<FirebaseAuthService>()) {
    sl.registerLazySingleton<FirebaseAuthService>(
          () => FirebaseAuthService(sl<FirebaseAuth>()),
    );
  }

  if (!sl.isRegistered<FirestoreService>()) {
    sl.registerLazySingleton<FirestoreService>(
          () => FirestoreService(sl<FirebaseFirestore>()),
    );
  }

  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(
          () => FcmService(
        sl<FirebaseMessaging>(),
        sl<FirebaseAuthService>(),
        sl<FirestoreService>(),
        sl<OrdersRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<NotificationsRemoteDataSource>()) {
    sl.registerLazySingleton<NotificationsRemoteDataSource>(
          () => NotificationsRemoteDataSource(
        sl<FirestoreService>(),
        sl<FirebaseAuthService>(),
      ),
    );
  }

  if (!sl.isRegistered<NotificationsRepository>()) {
    sl.registerLazySingleton<NotificationsRepository>(
          () => NotificationsRepository(sl<NotificationsRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<NotificationsCubit>()) {
    sl.registerFactory<NotificationsCubit>(
          () => NotificationsCubit(sl<NotificationsRepository>()),
    );
  }

  if (!sl.isRegistered<PetsRemoteDataSource>()) {
    sl.registerLazySingleton<PetsRemoteDataSource>(
          () => PetsRemoteDataSource(sl<FirebaseFirestore>()),
    );
  }

  if (!sl.isRegistered<PetsRepository>()) {
    sl.registerLazySingleton<PetsRepository>(
          () => PetsRepository(sl<PetsRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<PetsCubit>()) {
    sl.registerFactory<PetsCubit>(() => PetsCubit(sl<PetsRepository>()));
  }

  if (!sl.isRegistered<StoreRemoteDataSource>()) {
    sl.registerLazySingleton<StoreRemoteDataSource>(
          () => StoreRemoteDataSource(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
    );
  }

  if (!sl.isRegistered<StoreRepository>()) {
    sl.registerLazySingleton<StoreRepository>(
          () => StoreRepository(sl<StoreRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<StoreCubit>()) {
    sl.registerFactory<StoreCubit>(() => StoreCubit(sl<StoreRepository>()));
  }

  if (!sl.isRegistered<ProductDetailsCubit>()) {
    sl.registerFactory<ProductDetailsCubit>(
          () => ProductDetailsCubit(sl<StoreRepository>()),
    );
  }

  if (!sl.isRegistered<SearchCubit>()) {
    sl.registerFactory<SearchCubit>(() => SearchCubit(sl<StoreRepository>()));
  }

  if (!sl.isRegistered<CartRemoteDataSource>()) {
    sl.registerLazySingleton<CartRemoteDataSource>(
          () => CartRemoteDataSource(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
    );
  }

  if (!sl.isRegistered<CartRepository>()) {
    sl.registerLazySingleton<CartRepository>(
          () => CartRepository(sl<CartRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<CartCubit>()) {
    sl.registerFactory<CartCubit>(() => CartCubit(sl<CartRepository>()));
  }

  if (!sl.isRegistered<OrdersRemoteDataSource>()) {
    sl.registerLazySingleton<OrdersRemoteDataSource>(
          () => OrdersRemoteDataSource(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
    );
  }

  if (!sl.isRegistered<OrdersRepository>()) {
    sl.registerLazySingleton<OrdersRepository>(
          () => OrdersRepository(sl<OrdersRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<PaymentSimulator>()) {
    sl.registerLazySingleton<PaymentSimulator>(() => PaymentSimulator());
  }

  if (!sl.isRegistered<OrdersCubit>()) {
    sl.registerFactory<OrdersCubit>(() => OrdersCubit(sl<OrdersRepository>()));
  }

  if (!sl.isRegistered<CheckoutCubit>()) {
    sl.registerFactory<CheckoutCubit>(
          () => CheckoutCubit(
        sl<OrdersRepository>(),
        sl<PaymentSimulator>(),
        sl<CartRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
          () => ProfileRemoteDataSource(sl<FirebaseAuth>(), sl<FirestoreService>()),
    );
  }

  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
          () => ProfileRepository(sl<ProfileRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<ProfileCubit>()) {
    sl.registerFactory<ProfileCubit>(
          () => ProfileCubit(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<AdminRemoteDataSource>()) {
    sl.registerLazySingleton<AdminRemoteDataSource>(
          () => AdminRemoteDataSource(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
    );
  }

  if (!sl.isRegistered<AdminRepository>()) {
    sl.registerLazySingleton<AdminRepository>(
          () => AdminRepository(sl<AdminRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<AdminProductsCubit>()) {
    sl.registerFactory<AdminProductsCubit>(
          () => AdminProductsCubit(sl<AdminRepository>()),
    );
  }

  if (!sl.isRegistered<AdminOrdersCubit>()) {
    sl.registerFactory<AdminOrdersCubit>(
          () => AdminOrdersCubit(sl<AdminRepository>()),
    );
  }
}
