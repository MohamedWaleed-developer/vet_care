import 'package:injectable/injectable.dart';

import '../datasources/vaccinations_remote_data_source.dart';
import '../models/vaccination_model.dart';

// Repository مسؤول عن ربط الـ Cubit بالـ Data Source
@lazySingleton
class VaccinationsRepository {
  final VaccinationsRemoteDataSource remoteDataSource;

  VaccinationsRepository(this.remoteDataSource);

  // جلب تطعيمات حيوان معين
  Future<List<VaccinationModel>> getVaccinations(
      String petId,
      ) {
    return remoteDataSource.getVaccinations(petId);
  }

  // إضافة تطعيم
  Future<void> addVaccination(
      VaccinationModel vaccination,
      ) {
    return remoteDataSource.addVaccination(vaccination);
  }

  // تعديل تطعيم
  Future<void> updateVaccination(
      VaccinationModel vaccination,
      ) {
    return remoteDataSource.updateVaccination(vaccination);
  }

  // حذف تطعيم
  Future<void> deleteVaccination(
      String vaccinationId,
      ) {
    return remoteDataSource.deleteVaccination(vaccinationId);
  }
}