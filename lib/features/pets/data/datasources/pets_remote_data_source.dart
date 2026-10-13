import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/animal_model.dart';

class PetsRemoteDataSource {
  final FirebaseFirestore firestore;

  PetsRemoteDataSource(this.firestore);

  // =========================================================
  // جلب كل الحيوانات الخاصة بالمستخدم
  // =========================================================
  Future<List<AnimalModel>> getPets(String ownerId) async {
    final snapshot = await firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return AnimalModel(
        id: doc.id,
        name: data['name'] ?? '',

        gender: AnimalGender.values.firstWhere(
              (gender) => gender.name == data['gender'],
          orElse: () => AnimalGender.male,
        ),

        category: PetCategory.values.firstWhere(
              (category) => category.name == data['category'],
          orElse: () => PetCategory.cat,
        ),

        ageYears: data['ageYears'] ?? 0,
        ageMonths: data['ageMonths'] ?? 0,
        ageDays: data['ageDays'] ?? 1,

        breed: data['breed'] ?? '',

        weightKg: data['weightKg'] ?? 0,
        weightGrams: data['weightGrams'] ?? 0,

        lastRabiesDate: _dateFromFirestore(
          data['lastRabiesDate'],
        ),

        lastCoreDate: _dateFromFirestore(
          data['lastCoreDate'],
        ),

        lastSmallpoxDate: _dateFromFirestore(
          data['lastSmallpoxDate'],
        ),

        lastFmdDate: _dateFromFirestore(
          data['lastFmdDate'],
        ),

        lastMycoDate: _dateFromFirestore(
          data['lastMycoDate'],
        ),
      );
    }).toList();
  }

  // =========================================================
  // إضافة حيوان جديد
  //
  // بنرجع ID بتاع Firestore عشان نستخدمه كمفتاح للصورة في Hive
  // =========================================================
  Future<String> addPet(
      AnimalModel pet,
      String ownerId,
      ) async {
    final docRef = await firestore.collection('pets').add({
      'ownerId': ownerId,

      'name': pet.name,
      'gender': pet.gender.name,
      'category': pet.category.name,

      'ageYears': pet.ageYears,
      'ageMonths': pet.ageMonths,
      'ageDays': pet.ageDays,

      'breed': pet.breed,

      'weightKg': pet.weightKg,
      'weightGrams': pet.weightGrams,

      'lastRabiesDate': _dateToFirestore(
        pet.lastRabiesDate,
      ),

      'lastCoreDate': _dateToFirestore(
        pet.lastCoreDate,
      ),

      'lastSmallpoxDate': _dateToFirestore(
        pet.lastSmallpoxDate,
      ),

      'lastFmdDate': _dateToFirestore(
        pet.lastFmdDate,
      ),

      'lastMycoDate': _dateToFirestore(
        pet.lastMycoDate,
      ),
    });

    return docRef.id;
  }

  // =========================================================
  // تعديل حيوان
  // =========================================================
  Future<void> updatePet(
      String petId,
      AnimalModel pet,
      String ownerId,
      ) async {
    await firestore.collection('pets').doc(petId).update({
      'ownerId': ownerId,

      'name': pet.name,
      'gender': pet.gender.name,
      'category': pet.category.name,

      'ageYears': pet.ageYears,
      'ageMonths': pet.ageMonths,
      'ageDays': pet.ageDays,

      'breed': pet.breed,

      'weightKg': pet.weightKg,
      'weightGrams': pet.weightGrams,

      'lastRabiesDate': _dateToFirestore(
        pet.lastRabiesDate,
      ),

      'lastCoreDate': _dateToFirestore(
        pet.lastCoreDate,
      ),

      'lastSmallpoxDate': _dateToFirestore(
        pet.lastSmallpoxDate,
      ),

      'lastFmdDate': _dateToFirestore(
        pet.lastFmdDate,
      ),

      'lastMycoDate': _dateToFirestore(
        pet.lastMycoDate,
      ),
    });
  }

  Timestamp? _dateToFirestore(DateTime? date) {
    if (date == null) {
      return null;
    }

    return Timestamp.fromDate(date);
  }

  DateTime? _dateFromFirestore(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}