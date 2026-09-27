// بنستورد موديل التطعيمات
import '../../models/vaccination_model.dart';

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
  // الموعد الجديد يتم تأجيله إذا كان قريبًا من أي تطعيم
  // موجود في القائمة.
  //
  // مثال:
  // التطعيم الموجود: 1/3
  // الحد الأدنى: 15 يوم
  //
  // الموعد الجديد: 10/3
  // يصبح: 16/3
  // ---------------------------------------------------------
  static DateTime adjustDateForGap(
      DateTime targetDate,
      List<VaccinationModel> existingList, {
        required int gapDays,
      }) {
    DateTime adjustedDate = targetDate;

    bool changed;

    do {
      changed = false;

      for (final item in existingList) {
        final DateTime minimumAllowedDate = item.dueDate.add(
          Duration(days: gapDays),
        );

        if (adjustedDate.isBefore(minimumAllowedDate)) {
          adjustedDate = minimumAllowedDate;
          changed = true;
        }
      }
    } while (changed);

    return adjustedDate;
  }
}