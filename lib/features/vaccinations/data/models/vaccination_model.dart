class VaccinationModel {
  // ID الخاص بسجل التطعيم
  final String id;

  // ID الخاص بالحيوان صاحب التطعيم
  final String petId;

  // اسم التطعيم
  final String vaccineName;

  // موعد التطعيم المستحق
  final DateTime dueDate;

  VaccinationModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dueDate,
  });
}