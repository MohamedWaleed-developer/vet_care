// موديل التطعيم
import '../../models/vaccination_model.dart';

// أدوات التاريخ
import 'vaccination_date_helper.dart';


// Calculator خاص بالأغنام
class SheepVaccinationCalculator {

  // حساب جدول تطعيمات الأغنام
  static List<VaccinationModel> calculate({
    DateTime? lastSmallpoxDate,
    DateTime? lastFmdDate,
  }) {

    // قائمة التطعيمات
    final List<VaccinationModel> schedule = [];

    // تاريخ اليوم
    final DateTime now = DateTime.now();


    // =========================================================
    // تطعيم الجدري
    // =========================================================

    // لو مفيش تاريخ سابق → النهارده
    // لو فيه تاريخ سابق → بعد سنة
    final DateTime smallpoxDate = lastSmallpoxDate == null
        ? now
        : VaccinationDateHelper.addOneYear(lastSmallpoxDate);


    // التأكد من فرق 15 يوم
    final DateTime adjustedSmallpox =
    VaccinationDateHelper.adjustDateForGap(
      smallpoxDate,
      schedule,
      gapDays: 15,
    );


    // إضافة الجدري
    schedule.add(
      VaccinationModel(
        id: 'vac_s_sp',
        vaccineName: 'تطعيم الجدري',
        dueDate: adjustedSmallpox,
      ),
    );


    // =========================================================
    // الحمى القلاعية
    // =========================================================

    // كل 180 يوم تقريباً = 6 شهور
    final DateTime fmdDate = lastFmdDate == null
        ? now
        : lastFmdDate.add(
      const Duration(days: 180),
    );


    // التأكد من فرق 15 يوم
    final DateTime adjustedFmd =
    VaccinationDateHelper.adjustDateForGap(
      fmdDate,
      schedule,
      gapDays: 15,
    );


    // إضافة الحمى القلاعية
    schedule.add(
      VaccinationModel(
        id: 'vac_s_fmd',
        vaccineName: 'تطعيم الحمى القلاعية',
        dueDate: adjustedFmd,
      ),
    );


    // =========================================================
    // التطعيمات الموسمية
    // =========================================================

    _addSeasonalVaccines(
      schedule,
      gapDays: 15,
    );


    // ترتيب التطعيمات بالتاريخ
    schedule.sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
    );


    // إرجاع النتيجة
    return schedule;
  }


  // ===========================================================
  // إضافة التطعيمات الموسمية
  // ===========================================================
  static void _addSeasonalVaccines(
      List<VaccinationModel> schedule, {
        required int gapDays,
      }) {

    // تاريخ اليوم
    final DateTime now = DateTime.now();


    // =========================================================
    // التطعيم المعوي - أول يونيو
    // =========================================================

    // تحديد السنة المناسبة لشهر يونيو
    final int juneYear =
    (now.month > 6 || (now.month == 6 && now.day > 1))
        ? now.year + 1
        : now.year;


    // إنشاء تاريخ 1 يونيو
    DateTime juneDate = DateTime(
      juneYear,
      6,
      1,
    );


    // التأكد من فرق 15 يوم
    juneDate = VaccinationDateHelper.adjustDateForGap(
      juneDate,
      schedule,
      gapDays: gapDays,
    );


    // إضافة التطعيم المعوي
    schedule.add(
      VaccinationModel(
        id: 'vac_s_june_${juneDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم معوي (موسمي)',
        dueDate: juneDate,
      ),
    );


    // =========================================================
    // التطعيم الدموي والطاعون - أول مارس
    // =========================================================

    // تحديد السنة المناسبة لشهر مارس
    final int marchYear =
    (now.month > 3 || (now.month == 3 && now.day > 1))
        ? now.year + 1
        : now.year;


    // إنشاء تاريخ 1 مارس
    DateTime marchDate = DateTime(
      marchYear,
      3,
      1,
    );


    // التأكد من فرق 15 يوم
    marchDate = VaccinationDateHelper.adjustDateForGap(
      marchDate,
      schedule,
      gapDays: gapDays,
    );


    // إضافة التطعيم
    schedule.add(
      VaccinationModel(
        id: 'vac_s_march_${marchDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم دموي وطاعون (موسمي)',
        dueDate: marchDate,
      ),
    );
  }
}