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

// =========================
// Pets Feature
// =========================
import '../../features/pets/data/datasources/pets_remote_data_source.dart';
import '../../features/pets/data/repositories/pets_repository.dart';
import '../../features/pets/presentation/cubit/pets_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // =========================
  // Firebase Auth
  // =========================
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(
          () => FirebaseAuth.instance,
    );
  }

  // =========================
  // Firebase Firestore
  // =========================
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
          () => FirebaseFirestore.instance,
    );
  }

  // =========================
  // Firebase Messaging
  // =========================
  if (!sl.isRegistered<FirebaseMessaging>()) {
    sl.registerLazySingleton<FirebaseMessaging>(
          () => FirebaseMessaging.instance,
    );
  }

  // =========================
  // Dio
  // =========================
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient().dio,
    );
  }

  // =========================
  // Firebase Auth Service
  // =========================
  if (!sl.isRegistered<FirebaseAuthService>()) {
    sl.registerLazySingleton<FirebaseAuthService>(
          () => FirebaseAuthService(
        sl<FirebaseAuth>(),
      ),
    );
  }

  // =========================
  // Firestore Service
  // =========================
  if (!sl.isRegistered<FirestoreService>()) {
    sl.registerLazySingleton<FirestoreService>(
          () => FirestoreService(
        sl<FirebaseFirestore>(),
      ),
    );
  }

  // =========================
  // Notification Service
  // =========================
  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(
          () => FcmService(
        sl<FirebaseMessaging>(),
      ),
    );
  }

  // =========================
  // Pets Remote Data Source
  // =========================
  if (!sl.isRegistered<PetsRemoteDataSource>()) {
    sl.registerLazySingleton<PetsRemoteDataSource>(
          () => PetsRemoteDataSource(
        sl<FirebaseFirestore>(),
      ),
    );
  }

  // =========================
  // Pets Repository
  // =========================
  if (!sl.isRegistered<PetsRepository>()) {
    sl.registerLazySingleton<PetsRepository>(
          () => PetsRepository(
        sl<PetsRemoteDataSource>(),
      ),
    );
  }

  // =========================
  // Pets Cubit
  // =========================
  if (!sl.isRegistered<PetsCubit>()) {
    sl.registerFactory<PetsCubit>(
          () => PetsCubit(
        sl<PetsRepository>(),
      ),
    );
  }
}