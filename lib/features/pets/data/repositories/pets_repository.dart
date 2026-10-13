import '../datasources/pets_remote_data_source.dart';
import '../models/animal_model.dart';

class PetsRepository {
  final PetsRemoteDataSource remoteDataSource;

  PetsRepository(this.remoteDataSource);

  Future<List<AnimalModel>> getPets(String ownerId) {
    return remoteDataSource.getPets(ownerId);
  }

  // بيرجع ID الحيوان الجديد
  Future<String> addPet(
      AnimalModel pet,
      String ownerId,
      ) {
    return remoteDataSource.addPet(
      pet,
      ownerId,
    );
  }

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