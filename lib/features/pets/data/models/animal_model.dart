enum AnimalGender {
  male,
  female,
}

enum PetCategory {
  cat,
  dog,
  goat,
  sheep,
}

enum CoreVaccineType {
  none,
  triple,
  quadruple,
  quintuple,
  octuple,
}

class AnimalModel {
  final String name;
  final AnimalGender gender;
  final PetCategory category;

  final int ageInDays;
  final String breed;

  final int weightKg;
  final int weightGrams;

  // Cats & Dogs
  final DateTime? lastRabiesDate;
  final DateTime? lastCoreDate;
  final CoreVaccineType coreVaccineType;

  // Goats & Sheep
  final DateTime? lastSmallpoxDate;
  final DateTime? lastFmdDate;

  // Goats only
  final DateTime? lastMycoDate;

  AnimalModel({
    required this.name,
    required this.gender,
    required this.category,
    required this.ageInDays,
    required this.breed,
    required this.weightKg,
    required this.weightGrams,
    this.lastRabiesDate,
    this.lastCoreDate,
    this.coreVaccineType = CoreVaccineType.none,
    this.lastSmallpoxDate,
    this.lastFmdDate,
    this.lastMycoDate,
  });
}