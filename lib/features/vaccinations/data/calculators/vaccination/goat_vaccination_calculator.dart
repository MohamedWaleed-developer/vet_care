// أدوات التاريخ
import '../../models/vaccination_model.dart';
import 'vaccination_date_helper.dart';

// ===========================================================
// Calculator خاص بالماعز
// ===========================================================
class GoatVaccinationCalculator {
  // ---------------------------------------------------------
  // حساب جدول تطعيمات الماعز
  //
  // petId = ID الخاص بالماعز
  //
  // القواعد:
  //
  // الجدري            → كل سنة
  // FMD              → كل 6 شهور
  // Mycoplasma       → كل 6 شهور
  // المعوي            → أول يونيو من كل سنة
  // الدموي            → أول مارس من كل سنة
  // الطاعون           → أول مارس من كل سنة
  //
  // أقل فرق بين أي تطعيمين = 15 يوم
  // (يعني الطاعون بيجي بعد الدموي بـ 15 يوم: 16 مارس)
  // ---------------------------------------------------------
  static List<VaccinationModel> calculate({
    required String petId,
    DateTime? lastSmallpoxDate,
    DateTime? lastFmdDate,
    DateTime? lastMycoDate,
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
        id: 'vac_g_sp',
        petId: petId,
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
        id: 'vac_g_fmd',
        petId: petId,
        vaccineName: 'تطعيم الحمى القلاعية',
        dueDate: adjustedFmd,
      ),
    );

    // =========================================================
    // المايكوبلازما / أبو الرمح
    // =========================================================

    final DateTime mycoDate =
    lastMycoDate == null
        ? now
        : VaccinationDateHelper.addMonths(
      lastMycoDate,
      6,
    );

    final DateTime adjustedMyco =
    VaccinationDateHelper.adjustDateForGap(
      mycoDate,
      schedule,
      gapDays: 15,
    );

    schedule.add(
      VaccinationModel(
        id: 'vac_g_myco',
        petId: petId,
        vaccineName: 'تطعيم المايكوبلازما (أبو الرمح)',
        dueDate: adjustedMyco,
      ),
    );

    // =========================================================
    // التطعيمات الموسمية (دموي / طاعون / معوي)
    // =========================================================

    VaccinationDateHelper.addSeasonalVaccines(
      schedule,
      petId: petId,
      idPrefix: 'vac_g',
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
}