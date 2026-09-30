import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/vaccination_model.dart';
import '../../data/repositories/vaccinations_repository.dart';
import 'vaccinations_state.dart';

// Cubit مسؤول عن التحكم في حالة التطعيمات
@injectable
class VaccinationsCubit extends Cubit<VaccinationsState> {
  final VaccinationsRepository repository;

  VaccinationsCubit(this.repository)
      : super(VaccinationsInitial());

  // جلب التطعيمات الخاصة بحيوان معين
  Future<void> getVaccinations(String petId) async {
    emit(VaccinationsLoading());

    try {
      final vaccinations = await repository.getVaccinations(petId);

      emit(
        VaccinationsLoaded(vaccinations),
      );
    } catch (e) {
      emit(
        VaccinationsError(e.toString()),
      );
    }
  }

  // إضافة تطعيم
  Future<void> addVaccination(
      VaccinationModel vaccination,
      ) async {
    try {
      await repository.addVaccination(vaccination);

      // بعد الإضافة نجيب البيانات من جديد
      await getVaccinations(vaccination.petId);
    } catch (e) {
      emit(
        VaccinationsError(e.toString()),
      );
    }
  }

  // تعديل تطعيم
  Future<void> updateVaccination(
      VaccinationModel vaccination,
      ) async {
    try {
      await repository.updateVaccination(vaccination);

      await getVaccinations(vaccination.petId);
    } catch (e) {
      emit(
        VaccinationsError(e.toString()),
      );
    }
  }

  // حذف تطعيم
  Future<void> deleteVaccination(
      String vaccinationId,
      String petId,
      ) async {
    try {
      await repository.deleteVaccination(vaccinationId);

      await getVaccinations(petId);
    } catch (e) {
      emit(
        VaccinationsError(e.toString()),
      );
    }
  }
}