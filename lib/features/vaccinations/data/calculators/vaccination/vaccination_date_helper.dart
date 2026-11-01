// بنستورد موديل التطعيمات
import '../../models/vaccination_model.dart';

// تطعيم موسمي ثابت التاريخ كل سنة (للماعز والأغنام)
class _SeasonalSpec {
  final String key;
  final String name;
  final int month;
  final int day;

  const _SeasonalSpec(this.key, this.name, this.month, this.day);
}

// ===========================================================
// Vaccination Date Helper
// ===========================================================
//
// الملف ده مسؤول عن العمليات المشتركة الخاصة بالتواريخ
// بين كل أنواع الحيوانات.
// ===========================================================
class VaccinationDateHelper {
  // ---------------------------------------------------------
  // إضافة سنة كاملة على التاريخ
  // ---------------------------------------------------------
  static DateTime addOneYear(DateTime date) {
    return DateTime(
      date.year + 1,
      date.month,
      date.day,
    );
  }

  // ---------------------------------------------------------
  // إضافة عدد شهور حقيقي للتاريخ
  // ---------------------------------------------------------
  static DateTime addMonths(
      DateTime date,
      int months,
      ) {
    return DateTime(
      date.year,
      date.month + months,
      date.day,
    );
  }

  // ---------------------------------------------------------
  // التأكد من وجود الحد الأدنى للفاصل بين التطعيمات
  //
  // الموعد الجديد يتم تأجيله إذا كان قريبًا (أقل من gapDays
  // قبل أو بعد) من أي تطعيم موجود في القائمة.
  //
  // مثال:
  // التطعيم الموجود: 1/3
  // الحد الأدنى: 15 يوم
  //
  // الموعد الجديد: 10/3
  // يصبح: 16/3
  //
  // أما لو الموعد الجديد بعيد عن كل التطعيمات (أكتر من gapDays)
  // فبيفضل زي ما هو.
  // ---------------------------------------------------------
  static DateTime adjustDateForGap(
      DateTime targetDate,
      List<VaccinationModel> existingList, {
        required int gapDays,
      }) {
    return adjustDateAgainstDates(
      targetDate,
      existingList.map((item) => item.dueDate),
      gapDays: gapDays,
    );
  }

  // ---------------------------------------------------------
  // نفس الفكرة بس على قائمة تواريخ بدل قائمة تطعيمات
  // ---------------------------------------------------------
  static DateTime adjustDateAgainstDates(
      DateTime targetDate,
      Iterable<DateTime> existingDates, {
        required int gapDays,
      }) {
    DateTime adjustedDate = targetDate;

    bool changed;

    do {
      changed = false;

      for (final existing in existingDates) {
        // الفرق بين الموعدين بالأيام (موجب أو سالب)
        final int diffDays = adjustedDate.difference(existing).inDays;

        // قريب من التطعيم الموجود؟ (أقل من الحد الأدنى في أي اتجاه)
        if (diffDays.abs() < gapDays) {
          final DateTime minimumAllowedDate = existing.add(
            Duration(days: gapDays),
          );

          if (adjustedDate.isBefore(minimumAllowedDate)) {
            adjustedDate = minimumAllowedDate;
            changed = true;
          }
        }
      }
    } while (changed);

    return adjustedDate;
  }

  // ---------------------------------------------------------
  // التطعيمات الموسمية للماعز والأغنام (تاريخها ثابت كل سنة):
  //
  // الدموي   → أول مارس
  // الطاعون  → أول مارس (بعد الدموي بـ gapDays)
  // المعوي   → أول يونيو
  //
  // idPrefix: 'vac_g' للماعز و 'vac_s' للأغنام
  // ---------------------------------------------------------
  static const List<_SeasonalSpec> _seasonalSpecs = [
    _SeasonalSpec('blood', 'تطعيم دموي (موسمي)', 3, 1),
    _SeasonalSpec('plague', 'تطعيم طاعون (موسمي)', 3, 1),
    _SeasonalSpec('enteric', 'تطعيم معوي (موسمي)', 6, 1),
  ];

  // مواعيد التطعيمات الموسمية في سنة معينة، مع احترام الفاصل بينهم
  static List<DateTime> _seasonalDatesForYear(int year, int gapDays) {
    final dates = <DateTime>[];

    for (final spec in _seasonalSpecs) {
      dates.add(
        adjustDateAgainstDates(
          DateTime(year, spec.month, spec.day),
          dates,
          gapDays: gapDays,
        ),
      );
    }

    return dates;
  }

  static void addSeasonalVaccines(
      List<VaccinationModel> schedule, {
        required String petId,
        required String idPrefix,
        required int gapDays,
      }) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final thisYear = _seasonalDatesForYear(today.year, gapDays);
    final nextYear = _seasonalDatesForYear(today.year + 1, gapDays);

    for (var i = 0; i < _seasonalSpecs.length; i++) {
      final spec = _seasonalSpecs[i];

      // لو موعده السنة دي عدّى، ناخد موعد السنة الجاية
      DateTime date = thisYear[i].isBefore(today) ? nextYear[i] : thisYear[i];

      // نتأكد إن فيه فاصل كفاية بينه وبين باقي تطعيمات الحيوان
      date = adjustDateForGap(
        date,
        schedule,
        gapDays: gapDays,
      );

      schedule.add(
        VaccinationModel(
          id: '${idPrefix}_${spec.key}_${date.millisecondsSinceEpoch}',
          petId: petId,
          vaccineName: spec.name,
          dueDate: date,
        ),
      );
    }
  }
}