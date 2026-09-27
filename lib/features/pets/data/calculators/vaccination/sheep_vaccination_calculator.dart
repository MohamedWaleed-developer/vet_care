// موديل التطعيم
import '../../models/vaccination_model.dart';

// أدوات التاريخ
import 'vaccination_date_helper.dart';

// ===========================================================
// Calculator خاص بالأغنام
// ===========================================================
class SheepVaccinationCalculator {
  // ---------------------------------------------------------
  // قواعد تطعيم الأغنام:
  //
  // الجدري            → كل سنة
  // FMD              → كل 6 شهور
  // المعوي            → أول يونيو من كل سنة
  // الدموي/الطاعون   → أول مارس من كل سنة
  //
  // أقل فرق بين أي تطعيمين = 15 يوم
  // ---------------------------------------------------------
  static List<VaccinationModel> calculate({
    DateTime? lastSmallpoxDate,
    DateTime? lastFmdDate,
  }) {
    final List<VaccinationModel> schedule = [];

    final DateTime now = DateTime.now();

    // =========================================================
    // تطعيم الجدري
    // =========================================================

    final DateTime smallpoxDate =
    lastSmallpoxDate == null
        ? now
        : VaccinationDateHelper.addOneYear(
      lastSmallpoxDate,
    );

    final DateTime adjustedSmallpox =
    VaccinationDateHelper.adjustDateForGap(
      smallpoxDate,
      schedule,
      gapDays: 15,
    );

    schedule.add(
      VaccinationModel(
        id: 'vac_s_sp',
        vaccineName: 'تطعيم الجدري',
        dueDate: adjustedSmallpox,
      ),
    );

    // =========================================================
    // الحمى القلاعية FMD
    // =========================================================

    final DateTime fmdDate =
    lastFmdDate == null
        ? now
        : VaccinationDateHelper.addMonths(
      lastFmdDate,
      6,
    );

    final DateTime adjustedFmd =
    VaccinationDateHelper.adjustDateForGap(
      fmdDate,
      schedule,
      gapDays: 15,
    );

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

    // =========================================================
    // ترتيب النتيجة النهائية
    // =========================================================

    schedule.sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
    );

    return schedule;
  }

  // ===========================================================
  // إضافة التطعيمات الموسمية
  // ===========================================================
  static void _addSeasonalVaccines(
      List<VaccinationModel> schedule, {
        required int gapDays,
      }) {
    final DateTime now = DateTime.now();

    // =========================================================
    // التطعيم المعوي
    // الموعد الأساسي: أول يونيو
    // =========================================================

    final int juneYear =
    (now.month > 6 ||
        (now.month == 6 && now.day > 1))
        ? now.year + 1
        : now.year;

    DateTime juneDate = DateTime(
      juneYear,
      6,
      1,
    );

    juneDate = VaccinationDateHelper.adjustDateForGap(
      juneDate,
      schedule,
      gapDays: gapDays,
    );

    schedule.add(
      VaccinationModel(
        id: 'vac_s_june_${juneDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم معوي (موسمي)',
        dueDate: juneDate,
      ),
    );

    // =========================================================
    // التطعيم الدموي والطاعون
    // الموعد الأساسي: أول مارس
    // =========================================================

    final int marchYear =
    (now.month > 3 ||
        (now.month == 3 && now.day > 1))
        ? now.year + 1
        : now.year;

    DateTime marchDate = DateTime(
      marchYear,
      3,
      1,
    );

    marchDate = VaccinationDateHelper.adjustDateForGap(
      marchDate,
      schedule,
      gapDays: gapDays,
    );

    schedule.add(
      VaccinationModel(
        id: 'vac_s_march_${marchDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم دموي وطاعون (موسمي)',
        dueDate: marchDate,
      ),
    );
  }
}