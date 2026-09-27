// موديل التطعيم
import '../../models/vaccination_model.dart';

// أدوات التعامل مع التواريخ
import 'vaccination_date_helper.dart';

// Calculator خاص بالكلاب
class DogVaccinationCalculator {
  // الدالة الرئيسية لحساب جدول تطعيمات الكلب
  static List<VaccinationModel> calculate({
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

    // قائمة التطعيمات المطلوبة
    final List<VaccinationModel> schedule = [];

    // تاريخ اليوم
    final DateTime now = DateTime.now();

    // =========================================================
    // التطعيم الأساسي Core Vaccine
    // =========================================================

    // لو مفيش تطعيم أساسي سابق
    if (lastCoreDate == null) {
      // -------------------------------------------------------
      // من 60 إلى 75 يوم
      // -------------------------------------------------------
      if (ageInDays >= 60 && ageInDays <= 75) {
        // التطعيم الأول: رباعي
        schedule.add(
          VaccinationModel(
            id: 'vac_d1',
            vaccineName: 'التطعيم الرباعي',
            dueDate: now,
          ),
        );

        // الجرعة التنشيطية بعد 20 يوم
        schedule.add(
          VaccinationModel(
            id: 'vac_d2',
            vaccineName: 'جرعة تنشيطية (رباعي)',
            dueDate: now.add(
              const Duration(days: 20),
            ),
          ),
        );
      }

      // -------------------------------------------------------
      // أكبر من 75 يوم
      // -------------------------------------------------------
      else if (ageInDays > 75) {
        // التطعيم الأساسي: خماسي / ثماني
        schedule.add(
          VaccinationModel(
            id: 'vac_d3',
            vaccineName: 'التطعيم الخماسي / الثماني',
            dueDate: now,
          ),
        );

        // الجرعة التنشيطية بعد 20 يوم
        schedule.add(
          VaccinationModel(
            id: 'vac_d4',
            vaccineName: 'جرعة تنشيطية (خماسي / ثماني)',
            dueDate: now.add(
              const Duration(days: 20),
            ),
          ),
        );
      }
    }

    // =========================================================
    // لو عنده تطعيم أساسي سابق
    // =========================================================
    else {
      // التطعيم السنوي بعد سنة من آخر تطعيم أساسي
      final DateTime nextCore =
      VaccinationDateHelper.addOneYear(lastCoreDate);

      // إضافة التطعيم السنوي
      schedule.add(
        VaccinationModel(
          id: 'vac_d_annual',
          vaccineName: 'التطعيم الأساسي السنوي',
          dueDate: nextCore,
        ),
      );
    }

    // =========================================================
    // تطعيم السعار
    // =========================================================

    DateTime? rabiesDate;

    // لو لم يأخذ السعار من قبل
    if (lastRabiesDate == null) {
      // السعار يبدأ من عمر 3 شهور
      if (ageInDays >= 90) {
        rabiesDate = now;
      }
    }

    // لو أخده قبل كده
    else {
      // الموعد القادم بعد سنة
      rabiesDate =
          VaccinationDateHelper.addOneYear(lastRabiesDate);
    }

    // لو فيه موعد للسعار
    if (rabiesDate != null) {
      // التأكد من وجود 20 يوم على الأقل
      // بين السعار وأي تطعيم آخر
      rabiesDate = VaccinationDateHelper.adjustDateForGap(
        rabiesDate,
        schedule,
        gapDays: 20,
      );

      // إضافة السعار للقائمة
      schedule.add(
        VaccinationModel(
          id: 'vac_d_rabies',
          vaccineName: lastRabiesDate == null
              ? 'تطعيم السعار'
              : 'تطعيم السعار السنوي',
          dueDate: rabiesDate,
        ),
      );
    }

    // ترتيب التطعيمات حسب التاريخ
    schedule.sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
    );

    // إرجاع الجدول
    return schedule;
  }
}