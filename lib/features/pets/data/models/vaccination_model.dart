class VaccinationModel { //مودل التطعيم
  final String id;
  final String vaccineName;
  final DateTime dueDate;

  VaccinationModel({
    required this.id,
    required this.vaccineName,
    required this.dueDate,
  });
}