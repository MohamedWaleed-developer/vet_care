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

class AnimalModel {
  // ID الخاص بالحيوان في Firestore
  final String id;

  final String name;
  final AnimalGender gender;
  final PetCategory category;

  final int ageYears;
  final int ageMonths;
  final int ageDays;
  final String breed;

  final int weightKg;
  final int weightGrams;

  // Cats & Dogs
  final DateTime? lastRabiesDate;
  final DateTime? lastCoreDate;

  // Goats & Sheep
  final DateTime? lastSmallpoxDate;
  final DateTime? lastFmdDate;

  // Goats only
  final DateTime? lastMycoDate;

  AnimalModel({
    this.id = '',
    required this.name,
    required this.gender,
    required this.category,
    required this.ageYears,
    required this.ageMonths,
    required this.ageDays,
    required this.breed,
    required this.weightKg,
    required this.weightGrams,
    this.lastRabiesDate,
    this.lastCoreDate,
    this.lastSmallpoxDate,
    this.lastFmdDate,
    this.lastMycoDate,
  });
}