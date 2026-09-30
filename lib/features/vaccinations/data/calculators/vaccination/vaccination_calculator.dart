// بنستورد AnimalModel
// علشان نستقبل بيانات الحيوان
import '../../../../pets/data/models/animal_model.dart';

// موديل التطعيمات
import '../../models/vaccination_model.dart';

// Calculator القطط
import 'cat_vaccination_calculator.dart';

// Calculator الكلاب
import 'dog_vaccination_calculator.dart';

// Calculator الماعز
import 'goat_vaccination_calculator.dart';

// Calculator الأغنام
import 'sheep_vaccination_calculator.dart';

// ===========================================================
// الكلاس الرئيسي
// ===========================================================
//
// بدل ما الشاشة تعرف كل Calculator لوحده
// هي بس تستدعي VaccinationCalculator.
//
// وهو يحدد نوع الحيوان ويستخدم الـCalculator المناسب.
// ===========================================================
class VaccinationCalculator {
  // ---------------------------------------------------------
  // الدالة اللي هنستخدمها من بره
  //
  // بتاخد AnimalModel كامل
  // وترجع List من التطعيمات المطلوبة.
  // ---------------------------------------------------------
  static List<VaccinationModel> calculateForAnimal(
      AnimalModel animal,
      ) {
    // =======================================================
    // switch بتشوف نوع الحيوان
    // =======================================================
    switch (animal.category) {
    // -----------------------------------------------------
    // لو الحيوان قطة
    // -----------------------------------------------------
      case PetCategory.cat:
        return CatVaccinationCalculator.calculate(
          // ID الخاص بالقط
          petId: animal.id,

          // عمر القط
          ageYears: animal.ageYears,
          ageMonths: animal.ageMonths,
          ageDays: animal.ageDays,

          // آخر تطعيم أساسي
          lastCoreDate: animal.lastCoreDate,

          // آخر سعار
          lastRabiesDate: animal.lastRabiesDate,
        );

    // -----------------------------------------------------
    // لو الحيوان كلب
    // -----------------------------------------------------
      case PetCategory.dog:
        return DogVaccinationCalculator.calculate(
          // ID الخاص بالكلب
          petId: animal.id,

          // عمر الكلب
          ageYears: animal.ageYears,
          ageMonths: animal.ageMonths,
          ageDays: animal.ageDays,

          // آخر تطعيم أساسي
          lastCoreDate: animal.lastCoreDate,

          // آخر سعار
          lastRabiesDate: animal.lastRabiesDate,
        );

    // -----------------------------------------------------
    // لو الحيوان ماعز
    // -----------------------------------------------------
      case PetCategory.goat:
        return GoatVaccinationCalculator.calculate(
          // ID الخاص بالماعز
          petId: animal.id,

          // آخر جدري
          lastSmallpoxDate: animal.lastSmallpoxDate,

          // آخر حمى قلاعية
          lastFmdDate: animal.lastFmdDate,

          // آخر مايكوبلازما
          lastMycoDate: animal.lastMycoDate,
        );

    // -----------------------------------------------------
    // لو الحيوان خروف
    // -----------------------------------------------------
      case PetCategory.sheep:
        return SheepVaccinationCalculator.calculate(
          // ID الخاص بالخروف
          petId: animal.id,

          // آخر جدري
          lastSmallpoxDate: animal.lastSmallpoxDate,

          // آخر حمى قلاعية
          lastFmdDate: animal.lastFmdDate,
        );
    }
  }
}