import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/vaccination_model.dart';

// ===========================================================
// Vaccinations Remote Data Source
// ===========================================================
//
// مسؤول عن التعامل مع بيانات التطعيمات في Firestore.
//
// الـPetsRemoteDataSource مسؤول عن الحيوانات.
// أما هنا فإحنا مسؤولين عن التطعيمات فقط.
//
// كل تطعيم مربوط بحيوان عن طريق petId.
// ===========================================================
 @lazySingleton
class VaccinationsRemoteDataSource {
  final FirebaseFirestore firestore;

  VaccinationsRemoteDataSource(this.firestore);

  // =========================================================
  // getVaccinations
  // =========================================================
  //
  // جلب كل التطعيمات الخاصة بحيوان معين.
  //
  // بنستخدم petId علشان نجيب تطعيمات الحيوان المطلوب فقط.
  // =========================================================
  Future<List<VaccinationModel>> getVaccinations(
      String petId,
      ) async {
    final snapshot = await firestore
        .collection('vaccinations')
        .where('petId', isEqualTo: petId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return VaccinationModel(
        // ID الخاص بسجل التطعيم في Firestore
        id: doc.id,

        // ID الخاص بالحيوان
        petId: data['petId'] ?? '',

        // اسم التطعيم
        vaccineName: data['vaccineName'] ?? '',

        // موعد التطعيم
        dueDate: _dateFromFirestore(
          data['dueDate'],
        ) ?? DateTime.now(),
      );
    }).toList();
  }

  // =========================================================
  // addVaccination
  // =========================================================
  //
  // إضافة تطعيم جديد إلى Firestore.
  // =========================================================
  Future<void> addVaccination(
      VaccinationModel vaccination,
      ) async {
    await firestore.collection('vaccinations').add({
      // الحيوان صاحب التطعيم
      'petId': vaccination.petId,

      // اسم التطعيم
      'vaccineName': vaccination.vaccineName,

      // موعد التطعيم
      'dueDate': _dateToFirestore(
        vaccination.dueDate,
      ),
    });
  }

  // =========================================================
  // updateVaccination
  // =========================================================
  //
  // تعديل بيانات تطعيم موجود.
  // =========================================================
  Future<void> updateVaccination(
      VaccinationModel vaccination,
      ) async {
    await firestore
        .collection('vaccinations')
        .doc(vaccination.id)
        .update({
      // الحيوان صاحب التطعيم
      'petId': vaccination.petId,

      // اسم التطعيم
      'vaccineName': vaccination.vaccineName,

      // موعد التطعيم
      'dueDate': _dateToFirestore(
        vaccination.dueDate,
      ),
    });
  }

  // =========================================================
  // deleteVaccination
  // =========================================================
  //
  // حذف تطعيم من Firestore.
  // =========================================================
  Future<void> deleteVaccination(
      String vaccinationId,
      ) async {
    await firestore
        .collection('vaccinations')
        .doc(vaccinationId)
        .delete();
  }

  // =========================================================
  // تحويل DateTime إلى Timestamp
  // =========================================================
  //
  // Firestore بيخزن التاريخ كـ Timestamp.
  // =========================================================
  Timestamp _dateToFirestore(DateTime date) {
    return Timestamp.fromDate(date);
  }

  // =========================================================
  // تحويل Timestamp إلى DateTime
  // =========================================================
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