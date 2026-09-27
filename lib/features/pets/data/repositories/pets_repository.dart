import '../datasources/pets_remote_data_source.dart';
import '../models/animal_model.dart';

class PetsRepository {
  final PetsRemoteDataSource remoteDataSource;

  PetsRepository(this.remoteDataSource);

  // جلب كل الحيوانات الخاصة بالمستخدم
  Future<List<AnimalModel>> getPets(String ownerId) {
    return remoteDataSource.getPets(ownerId);
  }

  // إضافة حيوان جديد
  Future<void> addPet(
      AnimalModel pet,
      String ownerId,
      ) {
    return remoteDataSource.addPet(
      pet,
      ownerId,
    );
  }

  // تعديل بيانات حيوان
  Future<void> updatePet(
      String petId,
      AnimalModel pet,
      String ownerId,
      ) {
    return remoteDataSource.updatePet(
      petId,
      pet,
      ownerId,
    );
  }
}