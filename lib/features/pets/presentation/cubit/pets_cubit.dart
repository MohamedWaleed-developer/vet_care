import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/animal_model.dart';
import '../../data/repositories/pets_repository.dart';

// =========================================================
// حالات الـ Pets
// =========================================================

abstract class PetsState {}

// الحالة الابتدائية
class PetsInitial extends PetsState {}

// أثناء تحميل الحيوانات
class PetsLoading extends PetsState {}

// بعد نجاح جلب الحيوانات
class PetsLoaded extends PetsState {
  final List<AnimalModel> pets;

  PetsLoaded(this.pets);
}

// في حالة حدوث خطأ
class PetsError extends PetsState {
  final String message;

  PetsError(this.message);
}

// =========================================================
// Pets Cubit
// =========================================================

class PetsCubit extends Cubit<PetsState> {
  final PetsRepository repository;

  PetsCubit(this.repository) : super(PetsInitial());

  // =======================================================
  // جلب الحيوانات
  // =======================================================

  Future<void> getPets(String ownerId) async {
    emit(PetsLoading());

    try {
      final pets = await repository.getPets(ownerId);

      emit(PetsLoaded(pets));
    } catch (e) {
      emit(
        PetsError(
          'حدث خطأ أثناء تحميل الحيوانات',
        ),
      );
    }
  }

  // =======================================================
  // إضافة حيوان
  // =======================================================

  Future<void> addPet(
      AnimalModel pet,
      String ownerId,
      ) async {
    try {
      await repository.addPet(
        pet,
        ownerId,
      );

      // بعد الإضافة نعيد تحميل القائمة
      await getPets(ownerId);
    } catch (e) {
      emit(
        PetsError(
          'حدث خطأ أثناء إضافة الحيوان',
        ),
      );
    }
  }

  // =======================================================
  // تعديل حيوان
  // =======================================================

  Future<void> updatePet(
      String petId,
      AnimalModel pet,
      String ownerId,
      ) async {
    try {
      await repository.updatePet(
        petId,
        pet,
        ownerId,
      );

      // بعد التعديل نعيد تحميل القائمة
      await getPets(ownerId);
    } catch (e) {
      emit(
        PetsError(
          'حدث خطأ أثناء تعديل بيانات الحيوان',
        ),
      );
    }
  }
}