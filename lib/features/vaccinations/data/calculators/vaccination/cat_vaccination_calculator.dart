// Calculator خاص بالقطط فقط

import '../../models/vaccination_model.dart';
import 'vaccination_date_helper.dart';

class CatVaccinationCalculator {
  // ---------------------------------------------------------
  // الدالة الرئيسية لحساب جدول تطعيمات القط
  //
  // petId = ID الخاص بالحيوان
  // العمر = سنين + شهور + أيام
  // ---------------------------------------------------------
  static List<VaccinationModel> calculate({
    required String petId,
    required int ageYears,
    required int ageMonths,
    required int ageDays,
    DateTime? lastCoreDate,
    DateTime? lastRabiesDate,
  }) {
    // تحويل العمر إلى أيام
    //
    // السنة = 365 يوم
    // الشهر = 30 يوم
    final int ageInDays =
        (ageYears * 365) +
            (ageMonths * 30) +
            ageDays;

    // القائمة اللي هنحط فيها التطعيمات المطلوبة
    final List<VaccinationModel> schedule = [];

    // تاريخ اليوم
    final DateTime now = DateTime.now();

    // =========================================================
    // أولاً: التطعيم الأساسي Core Vaccine
    // =========================================================

    // لو مفيش تاريخ تطعيم أساسي سابق
    if (lastCoreDate == null) {
      // -------------------------------------------------------
      // من عمر شهرين إلى 4 شهور
      // 60 يوم إلى 120 يوم
      // -------------------------------------------------------
      if (ageInDays >= 60 && ageInDays <= 120) {
        // الجرعة الأولى: التطعيم الثلاثي
        schedule.add(
          VaccinationModel(
            id: 'vac_c1',
            petId: petId,
            vaccineName: 'التطعيم الثلاثي',
            dueDate: now,
          ),
        );

        // الجرعة التنشيطية بعد 21 يوم
        schedule.add(
          VaccinationModel(
            id: 'vac_c2',
            petId: petId,
            vaccineName: 'جرعة تنشيطية (ثلاثي)',
            dueDate: now.add(
              const Duration(days: 21),
            ),
          ),
        );
      }

      // -------------------------------------------------------
      // لو عمر القط أكبر من 4 شهور
      // -------------------------------------------------------
      else if (ageInDays > 120) {
        // الجرعة الأولى: التطعيم الرباعي
        schedule.add(
          VaccinationModel(
            id: 'vac_c3',
            petId: petId,
            vaccineName: 'التطعيم الرباعي',
            dueDate: now,
          ),
        );

        // الجرعة التنشيطية بعد 21 يوم
        schedule.add(
          VaccinationModel(
            id: 'vac_c4',
            petId: petId,
            vaccineName: 'جرعة تنشيطية (رباعي)',
            dueDate: now.add(
              const Duration(days: 21),
            ),
          ),
        );
      }
    }

    // =========================================================
    // لو القط عنده تطعيم أساسي سابق
    // =========================================================
    else {
      // التطعيم السنوي = بعد سنة من آخر تطعيم أساسي
      final DateTime nextCore =
      VaccinationDateHelper.addOneYear(lastCoreDate);

      // إضافة التطعيم السنوي
      schedule.add(
        VaccinationModel(
          id: 'vac_c_annual',
          petId: petId,
          vaccineName: 'التطعيم الرباعي السنوي',
          dueDate: nextCore,
        ),
      );
    }

    // =========================================================
    // ثانياً: تطعيم السعار Rabies
    // =========================================================

    DateTime? rabiesDate;

    // لو القط عمره ما أخد سعار
    if (lastRabiesDate == null) {
      // السعار يبدأ من عمر 3 شهور
      // 3 شهور = 90 يوم
      if (ageInDays >= 90) {
        rabiesDate = now;
      }
    }

    // لو القط أخد السعار قبل كده
    else {
      // موعد السعار القادم بعد سنة
      rabiesDate =
          VaccinationDateHelper.addOneYear(lastRabiesDate);
    }

    // لو قدرنا نحدد موعد للسعار
    if (rabiesDate != null) {
      // التأكد إن السعار مش قريب من تطعيم تاني
      // أقل فرق مسموح = 20 يوم
      rabiesDate = VaccinationDateHelper.adjustDateForGap(
        rabiesDate,
        schedule,
        gapDays: 20,
      );

      // إضافة السعار
      schedule.add(
        VaccinationModel(
          id: 'vac_c_rabies',
          petId: petId,
          vaccineName: lastRabiesDate == null
              ? 'تطعيم السعار'
              : 'تطعيم السعار السنوي',
          dueDate: rabiesDate,
        ),
      );
    }

    // =========================================================
    // ترتيب التطعيمات من الأقدم للأحدث
    // =========================================================
    schedule.sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
    );

    // إرجاع جدول التطعيمات النهائي
    return schedule;
  }
}