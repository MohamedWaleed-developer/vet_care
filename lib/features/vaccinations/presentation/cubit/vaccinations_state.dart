import '../../data/models/vaccination_model.dart';

// الحالة الأساسية لكل حالات التطعيمات
abstract class VaccinationsState {}

// الحالة الابتدائية
class VaccinationsInitial extends VaccinationsState {}

// حالة تحميل التطعيمات
class VaccinationsLoading extends VaccinationsState {}

// حالة نجاح جلب التطعيمات
class VaccinationsLoaded extends VaccinationsState {
  final List<VaccinationModel> vaccinations;

  VaccinationsLoaded(this.vaccinations);
}

// حالة حدوث خطأ
class VaccinationsError extends VaccinationsState {
  final String message;

  VaccinationsError(this.message);
}