import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/animal_model.dart';
import '../../data/repositories/pets_repository.dart';

abstract class PetsState {}

class PetsInitial extends PetsState {}

class PetsLoading extends PetsState {}

class PetsLoaded extends PetsState {
  final List<AnimalModel> pets;

  PetsLoaded(this.pets);
}

class PetsError extends PetsState {
  final String message;

  PetsError(this.message);
}

class PetsCubit extends Cubit<PetsState> {
  final PetsRepository repository;

  PetsCubit(this.repository) : super(PetsInitial());

  // =========================================================
  // جلب الحيوانات
  // =========================================================
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

  // =========================================================
  // إضافة حيوان
  //
  // بنرجع petId عشان الصورة تتخزن في Hive بنفس الـ ID
  // =========================================================
  Future<String?> addPet(
      AnimalModel pet,
      String ownerId,
      ) async {
    try {
      final petId = await repository.addPet(
        pet,
        ownerId,
      );

      await getPets(ownerId);

      return petId;
    } catch (e) {
      emit(
        PetsError(
          'حدث خطأ أثناء إضافة الحيوان',
        ),
      );

      return null;
    }
  }

  // =========================================================
  // تعديل حيوان
  // =========================================================
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