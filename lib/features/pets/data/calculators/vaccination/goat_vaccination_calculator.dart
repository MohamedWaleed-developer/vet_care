// موديل التطعيم
import '../../models/vaccination_model.dart';

// أدوات التاريخ
import 'vaccination_date_helper.dart';


// Calculator خاص بالماعز
class GoatVaccinationCalculator {

  // ---------------------------------------------------------
  // حساب جدول تطعيمات الماعز
  //
  // عندنا 3 تواريخ:
  // الجدري
  // الحمى القلاعية
  // المايكوبلازما
  // ---------------------------------------------------------
  static List<VaccinationModel> calculate({
    DateTime? lastSmallpoxDate,
    DateTime? lastFmdDate,
    DateTime? lastMycoDate,
  }) {

    // قائمة التطعيمات
    final List<VaccinationModel> schedule = [];

    // تاريخ اليوم
    final DateTime now = DateTime.now();


    // =========================================================
    // تطعيم الجدري
    // =========================================================

    // لو مفيش تاريخ سابق
    // يبقى الموعد = النهارده
    //
    // لو فيه تاريخ سابق
    // يبقى بعد سنة
    final DateTime smallpoxDate = lastSmallpoxDate == null
        ? now
        : VaccinationDateHelper.addOneYear(lastSmallpoxDate);


    // نتأكد إن فيه 15 يوم على الأقل
    // بينه وبين التطعيمات الموجودة
    final DateTime adjustedSmallpox =
    VaccinationDateHelper.adjustDateForGap(
      smallpoxDate,
      schedule,
      gapDays: 15,
    );


    // إضافة الجدري
    schedule.add(
      VaccinationModel(
        id: 'vac_g_sp',
        vaccineName: 'تطعيم الجدري',
        dueDate: adjustedSmallpox,
      ),
    );


    // =========================================================
    // الحمى القلاعية FMD
    // =========================================================

    // لو مفيش تطعيم سابق
    // يبقى النهارده
    //
    // لو فيه تطعيم سابق
    // يبقى بعد 180 يوم تقريباً = 6 شهور
    final DateTime fmdDate = lastFmdDate == null
        ? now
        : lastFmdDate.add(
      const Duration(days: 180),
    );


    // التأكد من وجود 15 يوم بين التطعيمات
    final DateTime adjustedFmd =
    VaccinationDateHelper.adjustDateForGap(
      fmdDate,
      schedule,
      gapDays: 15,
    );


    // إضافة تطعيم الحمى القلاعية
    schedule.add(
      VaccinationModel(
        id: 'vac_g_fmd',
        vaccineName: 'تطعيم الحمى القلاعية',
        dueDate: adjustedFmd,
      ),
    );


    // =========================================================
    // المايكوبلازما / أبو الرمح
    // =========================================================

    // نفس فكرة الحمى القلاعية
    // كل 180 يوم
    final DateTime mycoDate = lastMycoDate == null
        ? now
        : lastMycoDate.add(
      const Duration(days: 180),
    );


    // التأكد من فرق 15 يوم
    final DateTime adjustedMyco =
    VaccinationDateHelper.adjustDateForGap(
      mycoDate,
      schedule,
      gapDays: 15,
    );


    // إضافة التطعيم
    schedule.add(
      VaccinationModel(
        id: 'vac_g_myco',
        vaccineName: 'تطعيم المايكروبلازما (أبو الرمح)',
        dueDate: adjustedMyco,
      ),
    );


    // =========================================================
    // التطعيمات الموسمية
    // =========================================================

    _addSeasonalVaccines(
      schedule,
      gapDays: 15,
    );


    // ترتيب كل التطعيمات بالتاريخ
    schedule.sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
    );


    // إرجاع الجدول النهائي
    return schedule;
  }


  // ===========================================================
  // دالة إضافة التطعيمات الموسمية
  // ===========================================================
  static void _addSeasonalVaccines(
      List<VaccinationModel> schedule, {
        required int gapDays,
      }) {

    // تاريخ اليوم
    final DateTime now = DateTime.now();


    // =========================================================
    // التطعيم المعوي
    // موعده الأساسي أول يونيو
    // =========================================================

    // لو عدينا أول يونيو من السنة الحالية
    // نستخدم يونيو السنة القادمة
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
        id: 'vac_g_june_${juneDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم معوي (موسمي)',
        dueDate: juneDate,
      ),
    );


    // =========================================================
    // التطعيم الدموي والطاعون
    // موعده الأساسي أول مارس
    // =========================================================

    // لو عدينا أول مارس
    // نستخدم مارس السنة القادمة
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


    // التأكد من وجود فرق 15 يوم
    marchDate = VaccinationDateHelper.adjustDateForGap(
      marchDate,
      schedule,
      gapDays: gapDays,
    );


    // إضافة التطعيم
    schedule.add(
      VaccinationModel(
        id: 'vac_g_march_${marchDate.millisecondsSinceEpoch}',
        vaccineName: 'تطعيم دموي وطاعون (موسمي)',
        dueDate: marchDate,
      ),
    );
  }
}