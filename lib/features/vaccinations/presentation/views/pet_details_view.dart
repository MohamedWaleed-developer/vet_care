import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../pets/data/models/animal_model.dart';
import '../../data/models/vaccination_model.dart';
import 'vaccination_details_view.dart';

// ===========================================================
// الألوان
// ===========================================================

const _kDark = Color(0xFF173F3F);
const _kGreen = Color(0xFF178B82);
const _kGreenLight = Color(0xFFE6F4F2);
const _kGrey = Color(0xFF718181);
const _kBorder = Color(0xFFE5ECEC);
const _kBackground = Color(0xFFF7F9F9);

const _kAmber = Color(0xFF9A7410);
const _kAmberBg = Color(0xFFFFF4D8);
const _kAmberChip = Color(0xFFFFE6A8);

const _kRed = Color(0xFFC84A4A);
const _kRedBg = Color(0xFFFFE7E7);
const _kRedChip = Color(0xFFFFD0D0);

enum _PetTab { info, vaccinations, records }

// ===========================================================
// ربط التطعيمات بالـ calculators
// ===========================================================
//
// الـ calculators بترجع VaccinationModel بـ id ثابت لكل تطعيم.
// من الـ id بنعرف التطعيم ده تابع لأنهي "آخر جرعة" في AnimalModel.
// لو غيّرت الـ ids في الـ calculators لازم تتغير هنا كمان.

/// آخر جرعة اللي ممكن تتحدث: rabies / core / smallpox / fmd / myco
const List<String> _lastKeys = ['rabies', 'core', 'smallpox', 'fmd', 'myco'];

/// التطعيمات الموسمية (تاريخها ثابت كل سنة): دموي / طاعون / معوي
const List<String> _seasonKeys = ['blood', 'plague', 'enteric'];

String? _trackKeyOf(String id) {
  if (id.contains('rabies')) return 'rabies';
  if (id.contains('_blood_')) return 'blood';
  if (id.contains('_plague_')) return 'plague';
  if (id.contains('_enteric_')) return 'enteric';
  if (id.endsWith('_sp')) return 'smallpox';
  if (id.endsWith('_fmd')) return 'fmd';
  if (id.endsWith('_myco')) return 'myco';
  if (id.startsWith('vac_c') || id.startsWith('vac_d')) return 'core';
  return null;
}

/// مفتاح ثابت للتطعيم عشان نحفظ عليه الموعد اللي المستخدم عدّله.
/// التطعيمات الموسمية id بتاعها بيتغير مع التاريخ، فبنستخدم اسم نوعها.
String _overrideKeyOf(String id) {
  final track = _trackKeyOf(id);
  if (track != null && _seasonKeys.contains(track)) return track;
  return id;
}

/// الجرعة الأولى للقطط والكلاب → الجرعة التنشيطية بتاعتها
const Map<String, String> _boosterOf = {
  'vac_c1': 'vac_c2',
  'vac_c3': 'vac_c4',
  'vac_d1': 'vac_d2',
  'vac_d3': 'vac_d4',
};

/// جرعة تنشيطية مستنية بعد ما المستخدم أكد الجرعة الأولى
class _Followup {
  final String id;
  final String name;
  final DateTime due;

  const _Followup({required this.id, required this.name, required this.due});
}

// ===========================================================
// دوال التواريخ والنصوص
// ===========================================================

const List<String> _arMonthNames = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// عدد الأيام بين تاريخين (بدون تأثير تغيير التوقيت الصيفي)
int _daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

DateTime _addMonths(DateTime d, int months) {
  final total = d.month - 1 + months;
  final year = d.year + total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = d.day > lastDay ? lastDay : d.day;
  return DateTime(year, month, day);
}

class _Span {
  final int months;
  final int days;

  const _Span(this.months, this.days);
}

/// الفرق بين تاريخين بالشهور والأيام (from قبل to)
_Span _span(DateTime from, DateTime to) {
  int months = (to.year - from.year) * 12 + (to.month - from.month);
  if (to.day < from.day) months -= 1;
  if (months < 0) months = 0;

  final anchor = _addMonths(from, months);
  int days = _daysBetween(anchor, to);
  if (days < 0) days = 0;

  return _Span(months, days);
}

String _arCount(
    int n, {
      required String one,
      required String two,
      required String few,
      required String many,
    }) {
  if (n == 1) return one;
  if (n == 2) return two;
  if (n >= 3 && n <= 10) return '$n $few';
  return '$n $many';
}

String _monthsText(int n) =>
    _arCount(n, one: 'شهر', two: 'شهرين', few: 'شهور', many: 'شهراً');

String _daysText(int n) =>
    _arCount(n, one: 'يوم', two: 'يومين', few: 'أيام', many: 'يوماً');

String _yearsText(int n) =>
    _arCount(n, one: 'سنة', two: 'سنتين', few: 'سنوات', many: 'سنة');

String _spanText(_Span s) {
  if (s.months > 0 && s.days > 0) {
    return '${_monthsText(s.months)} و ${_daysText(s.days)}';
  }
  if (s.months > 0) return _monthsText(s.months);
  return _daysText(s.days);
}

String _formatDate(DateTime d) =>
    '${d.day} ${_arMonthNames[d.month - 1]} ${d.year}';

/// الوقت المتبقي أو المتأخر عن موعد معين، كجملة
String _countdownSentence(DateTime due) {
  final today = _dateOnly(DateTime.now());
  final day = _dateOnly(due);
  final left = _daysBetween(today, day);

  if (left == 0) return 'الموعد اليوم';
  if (left < 0) return 'متأخر منذ ${_spanText(_span(day, today))}';
  return 'متبقي ${_spanText(_span(today, day))}';
}

/// العمر زي ما المستخدم دخله. بترجع null لو كله صفر.
String? _ageTextFrom(int years, int months, int days) {
  final parts = <String>[];

  if (years > 0) parts.add(_yearsText(years));
  if (months > 0) parts.add(_monthsText(months));
  if (days > 0) parts.add(_daysText(days));

  if (parts.isEmpty) return null;
  return parts.join(' و ');
}

String? _weightTextFrom(int kg, int grams) {
  if (kg > 0 && grams > 0) return '$kg كجم و $grams جم';
  if (kg > 0) return '$kg كجم';
  if (grams > 0) return '$grams جم';
  return null;
}

DateTime? _latest(DateTime? a, DateTime? b) {
  if (a == null) return b == null ? null : _dateOnly(b);
  if (b == null) return _dateOnly(a);
  final x = _dateOnly(a);
  final y = _dateOnly(b);
  return y.isAfter(x) ? y : x;
}

String? _categoryLabel(PetCategory category) {
  switch (category) {
    case PetCategory.cat:
      return 'قطة';
    case PetCategory.dog:
      return 'كلب';
    case PetCategory.goat:
      return 'ماعز';
    case PetCategory.sheep:
      return 'خروف';
  }
}

// ===========================================================
// الصفحة
// ===========================================================

/// صفحة تفاصيل الحيوان.
///
/// جدول التطعيمات بييجي من [scheduleBuilder] (يعني VaccinationCalculator)،
/// فالقواعد الطبية كلها في الـ calculators مش هنا.
class PetDetailsView extends StatefulWidget {
  final AnimalModel animal;

  /// مثال: VaccinationCalculator.calculateForAnimal
  final List<VaccinationModel> Function(AnimalModel animal) scheduleBuilder;

  final ImageProvider? image;

  const PetDetailsView({
    super.key,
    required this.animal,
    required this.scheduleBuilder,
    this.image,
  });

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  _PetTab _selectedTab = _PetTab.vaccinations;

  bool _loaded = false;

  /// آخر جرعة اتأكدت من الشاشة (بتتقارن بالمسجل مع الحيوان وناخد الأحدث)
  Map<String, DateTime> _localLast = <String, DateTime>{};

  /// آخر سنة اتأكد فيها التطعيم الموسمي (blood / plague / enteric)
  Map<String, int> _localSeason = <String, int>{};

  /// الجرعة التنشيطية اللي مستنية (لو في)
  _Followup? _followup;

  /// المواعيد اللي المستخدم عدّلها بإيده (المفتاح من _overrideKeyOf)
  Map<String, DateTime> _overrides = <String, DateTime>{};

  Timer? _timer;

  AnimalModel get _animal => widget.animal;

  bool get _isLivestock =>
      _animal.category == PetCategory.goat ||
          _animal.category == PetCategory.sheep;

  @override
  void initState() {
    super.initState();

    _loadProgress();

    // نحدّث العد التنازلي كل دقيقة
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===========================================================
  // التخزين المحلي
  // ===========================================================

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = _animal.id;

      final last = <String, DateTime>{};
      for (final key in _lastKeys) {
        final raw = prefs.getString('vac_last_${id}_$key');
        final d = raw == null ? null : DateTime.tryParse(raw);
        if (d != null) last[key] = _dateOnly(d);
      }

      final season = <String, int>{};
      for (final key in _seasonKeys) {
        final year = prefs.getInt('vac_season_${id}_$key');
        if (year != null) season[key] = year;
      }

      _Followup? followup;
      final rawFollow = prefs.getString('vac_follow_$id');
      if (rawFollow != null) {
        final parts = rawFollow.split('|');
        if (parts.length >= 3) {
          final due = DateTime.tryParse(parts.last);
          if (due != null) {
            followup = _Followup(
              id: parts.first,
              name: parts.sublist(1, parts.length - 1).join('|'),
              due: _dateOnly(due),
            );
          }
        }
      }

      final overrides = <String, DateTime>{};
      final rawOverrides =
          prefs.getStringList('vac_overrides_$id') ?? const <String>[];
      for (final entry in rawOverrides) {
        final i = entry.lastIndexOf('|');
        if (i <= 0) continue;

        final d = DateTime.tryParse(entry.substring(i + 1));
        if (d != null) overrides[entry.substring(0, i)] = _dateOnly(d);
      }

      if (!mounted) return;
      setState(() {
        _localLast = last;
        _localSeason = season;
        _followup = followup;
        _overrides = overrides;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _saveProgress({
    String? lastKey,
    DateTime? lastDate,
    String? seasonKey,
    int? seasonYear,
    bool saveFollowup = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = _animal.id;

      if (lastKey != null && lastDate != null) {
        await prefs.setString(
          'vac_last_${id}_$lastKey',
          lastDate.toIso8601String(),
        );
      }

      if (seasonKey != null && seasonYear != null) {
        await prefs.setInt('vac_season_${id}_$seasonKey', seasonYear);
      }

      if (saveFollowup) {
        final f = _followup;
        if (f == null) {
          await prefs.remove('vac_follow_$id');
        } else {
          await prefs.setString(
            'vac_follow_$id',
            '${f.id}|${f.name}|${f.due.toIso8601String()}',
          );
        }
      }

      // المواعيد المعدلة بتتحفظ دايماً
      await prefs.setStringList(
        'vac_overrides_$id',
        _overrides.entries
            .map((e) => '${e.key}|${e.value.toIso8601String()}')
            .toList(),
      );
    } catch (_) {
      // لو التخزين فشل، الشاشة تفضل شغالة لحد ما التطبيق يتقفل
    }
  }

  // ===========================================================
  // حساب الجدول
  // ===========================================================

  /// الحيوان بعد دمج آخر جرعة اتأكدت من الشاشة
  AnimalModel _effectiveAnimal() {
    final a = _animal;

    return AnimalModel(
      id: a.id,
      name: a.name,
      gender: a.gender,
      category: a.category,
      ageYears: a.ageYears,
      ageMonths: a.ageMonths,
      ageDays: a.ageDays,
      breed: a.breed,
      weightKg: a.weightKg,
      weightGrams: a.weightGrams,
      lastRabiesDate: _latest(a.lastRabiesDate, _localLast['rabies']),
      lastCoreDate: _latest(a.lastCoreDate, _localLast['core']),
      lastSmallpoxDate: _latest(a.lastSmallpoxDate, _localLast['smallpox']),
      lastFmdDate: _latest(a.lastFmdDate, _localLast['fmd']),
      lastMycoDate: _latest(a.lastMycoDate, _localLast['myco']),
    );
  }

  DateTime? _lastOfTrack(AnimalModel a, String? key) {
    switch (key) {
      case 'rabies':
        return a.lastRabiesDate;
      case 'core':
        return a.lastCoreDate;
      case 'smallpox':
        return a.lastSmallpoxDate;
      case 'fmd':
        return a.lastFmdDate;
      case 'myco':
        return a.lastMycoDate;
      default:
        return null;
    }
  }

  List<VaccinationModel> _computeSchedule(AnimalModel effective) {
    final calculated = widget.scheduleBuilder(effective);
    final result = <VaccinationModel>[];

    for (final v in calculated) {
      final key = _trackKeyOf(v.id);

      // تطعيم موسمي اتأكد خلاص: نخفيه لحد ما تيجي السنة الجاية
      if (key != null && _seasonKeys.contains(key)) {
        final doneYear = _localSeason[key];
        if (doneYear != null && v.dueDate.year <= doneYear) continue;
      }

      result.add(v);
    }

    final f = _followup;
    if (f != null) {
      result.add(
        VaccinationModel(
          id: f.id,
          petId: _animal.id,
          vaccineName: f.name,
          dueDate: f.due,
        ),
      );
    }

    // المواعيد اللي المستخدم عدّلها بإيده
    final withOverrides = result.map((v) {
      final custom = _overrides[_overrideKeyOf(v.id)];
      if (custom == null) return v;

      return VaccinationModel(
        id: v.id,
        petId: _animal.id,
        vaccineName: v.vaccineName,
        dueDate: custom,
      );
    }).toList();

    withOverrides.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return withOverrides;
  }

  // ===========================================================
  // تسجيل إن الحيوان اتطعّم
  // ===========================================================

  Future<void> _markGiven(VaccinationModel item) async {
    final key = _trackKeyOf(item.id);
    if (key == null || !mounted) return;

    // الجدول الأصلي من الـ calculator (من غير مواعيد المستخدم المعدلة)
    final raw = widget.scheduleBuilder(_effectiveAnimal());

    // الموعد المعدل للتطعيم ده مبقاش له لزوم
    final overrides = Map<String, DateTime>.from(_overrides)
      ..remove(_overrideKeyOf(item.id));

    // تطعيم موسمي: نخفي اللي اتأكد ونستنى السنة الجاية
    if (_seasonKeys.contains(key)) {
      int year = item.dueDate.year;
      for (final v in raw) {
        if (_trackKeyOf(v.id) == key) {
          year = v.dueDate.year;
          break;
        }
      }

      setState(() {
        _localSeason = <String, int>{..._localSeason, key: year};
        _overrides = overrides;
      });

      await _saveProgress(seasonKey: key, seasonYear: year);
      return;
    }

    final today = _dateOnly(DateTime.now());

    // لو ده تأكيد للجرعة التنشيطية المستنية، نشيلها
    _Followup? newFollowup = _followup;
    if (newFollowup != null && newFollowup.id == item.id) {
      newFollowup = null;
    }

    // لو دي الجرعة الأولى، الجرعة التنشيطية بتيجي بنفس الفاصل اللي في الـ calculator
    final boosterId = _boosterOf[item.id];
    if (boosterId != null) {
      VaccinationModel? primaryRaw;
      VaccinationModel? boosterRaw;

      for (final v in raw) {
        if (v.id == item.id) primaryRaw = v;
        if (v.id == boosterId) boosterRaw = v;
      }

      if (primaryRaw != null && boosterRaw != null) {
        final gap = _daysBetween(
          _dateOnly(primaryRaw.dueDate),
          _dateOnly(boosterRaw.dueDate),
        );

        newFollowup = _Followup(
          id: boosterRaw.id,
          name: boosterRaw.vaccineName,
          due: _addDays(today, gap),
        );

        overrides.remove(boosterId);
      }
    }

    setState(() {
      _localLast = <String, DateTime>{..._localLast, key: today};
      _followup = newFollowup;
      _overrides = overrides;
    });

    await _saveProgress(
      lastKey: key,
      lastDate: today,
      saveFollowup: true,
    );
  }

  // ===========================================================
  // تعديل المواعيد
  // ===========================================================

  Future<void> _setOverride(VaccinationModel item, DateTime date) async {
    if (!mounted) return;

    setState(() {
      _overrides = <String, DateTime>{
        ..._overrides,
        _overrideKeyOf(item.id): _dateOnly(date),
      };
    });

    await _saveProgress();
  }

  Future<void> _clearOverride(VaccinationModel item) async {
    if (!mounted) return;

    setState(() {
      _overrides = Map<String, DateTime>.from(_overrides)
        ..remove(_overrideKeyOf(item.id));
    });

    await _saveProgress();
  }

  Future<DateTime?> _pickDate(DateTime current) {
    final today = _dateOnly(DateTime.now());
    final first = DateTime(today.year - 1, today.month, today.day);
    final last = DateTime(today.year + 3, today.month, today.day);

    DateTime initial = _dateOnly(current);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'اختر موعد التطعيم',
    );
  }

  /// زرار القلم: بيفتح قائمة بمواعيد التطعيمات ويسمح بتعديل كل موعد
  Future<void> _openEditDates() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final schedule = _loaded
                  ? _computeSchedule(_effectiveAnimal())
                  : <VaccinationModel>[];

              return SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تعديل مواعيد التطعيمات',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _kDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'اضغط على التطعيم لتغيير موعده.',
                          style: TextStyle(fontSize: 12, color: _kGrey),
                        ),

                        const SizedBox(height: 14),

                        if (schedule.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'لا توجد تطعيمات لتعديلها.',
                                style: TextStyle(fontSize: 13, color: _kGrey),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: schedule.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final item = schedule[index];
                                final edited =
                                _overrides.containsKey(_overrideKeyOf(item.id));

                                return _buildEditRow(
                                  item,
                                  edited: edited,
                                  onChanged: () => setSheetState(() {}),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEditRow(
      VaccinationModel item, {
        required bool edited,
        required VoidCallback onChanged,
      }) {
    return Material(
      color: _kBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await _pickDate(item.dueDate);
          if (picked == null) return;

          await _setOverride(item, picked);
          onChanged();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.vaccineName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatDate(_dateOnly(item.dueDate)) +
                          (edited ? '  (معدّل)' : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: edited ? _kGreen : _kGrey,
                      ),
                    ),

                    if (edited) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          await _clearOverride(item);
                          onChanged();
                        },
                        child: const Text(
                          'إعادة الموعد الأصلي',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(Icons.edit_calendar_outlined, color: _kGreen),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // شاشة تفاصيل اللقاح
  // ===========================================================

  Future<void> _openDetails(VaccinationModel item, AnimalModel effective) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VaccinationDetailsView(
          vaccineName: item.vaccineName,
          description: _descriptionFor(item),
          dueDate: item.dueDate,
          lastDate: _lastOfTrack(effective, _trackKeyOf(item.id)),
          petName: _animal.name,
          petSubtitle: _breedAndGender(),
          petImage: widget.image,
          formatDate: (d) => _formatDate(_dateOnly(d)),
          countdownText: _countdownSentence,
          onMarkGiven: () => _markGiven(item),
          onChangeDate: (d) => _setOverride(item, d),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('تم تسجيل التطعيم.')),
        );
    }
  }

  /// نبذة عن اللقاح (نص عام، راجعه مع طبيبك البيطري)
  String _descriptionFor(VaccinationModel v) {
    if (_boosterOf.values.contains(v.id)) {
      return 'جرعة تنشيطية تُعطى بعد الجرعة الأولى بحوالي 3 أسابيع، '
          'لتكتمل مناعة الحيوان ضد المرض.';
    }

    final isCat = _animal.category == PetCategory.cat;

    switch (_trackKeyOf(v.id)) {
      case 'rabies':
        return 'يحمي الحيوان من فيروس السعار، وهو مرض خطير ينتقل للإنسان '
            'ويصيب الجهاز العصبي. يُعطى مرة كل سنة.';
      case 'core':
        return isCat
            ? 'تطعيم أساسي يحمي القطط من الأمراض الفيروسية الشائعة مثل '
            'الرشح الفيروسي والكاليسي والبانليوكوبينيا. يُكرَّر كل سنة '
            'بعد الجرعات الأولى.'
            : 'تطعيم أساسي يحمي الكلاب من الأمراض الفيروسية الشائعة مثل '
            'الديستمبر والبارفو. يُكرَّر كل سنة بعد الجرعات الأولى.';
      case 'smallpox':
        return 'يحمي الحيوان من الجدري، وهو مرض فيروسي معدٍ. يُعطى مرة كل سنة.';
      case 'fmd':
        return 'يحمي الحيوان من الحمى القلاعية، وهي مرض فيروسي شديد العدوى. '
            'يُعطى كل 6 شهور.';
      case 'myco':
        return 'يحمي الماعز من الميكوبلازما (أبو الرمح)، وهو مرض يصيب الجهاز '
            'التنفسي. يُعطى كل 6 شهور.';
      case 'blood':
        return 'تطعيم دموي موسمي لحماية القطيع، موعده الثابت أول مارس من كل سنة.';
      case 'plague':
        return 'تطعيم الطاعون لحماية القطيع من المرض الفيروسي، موعده أول مارس '
            'من كل سنة، وبيجي بعد الدموي بـ 15 يوم.';
      case 'enteric':
        return 'تطعيم معوي موسمي لحماية القطيع من الأمراض المعوية، موعده '
            'الثابت أول يونيو من كل سنة.';
      default:
        return 'تطعيم ضمن جدول الرعاية الصحية للحيوان.';
    }
  }

  // ===========================================================
  // الصفحة
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _kBackground,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderImage(context),

              const SizedBox(height: 16),

              Text(
                _animal.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _breedAndGender(),
                style: const TextStyle(
                  fontSize: 14,
                  color: _kGrey,
                ),
              ),

              ..._buildStatsSection(),

              const SizedBox(height: 20),

              _buildTabs(),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTabContent(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// السلالة والجنس زي ما اتدخلوا (من غير سلالة فاضية)
  String _breedAndGender() {
    final breed = _animal.breed.trim();
    final gender = _animal.gender == AnimalGender.male ? 'ذكر' : 'أنثى';

    return breed.isEmpty ? gender : '$breed · $gender';
  }

  // ===========================================================
  // صورة الحيوان + أزرار الرجوع والتعديل
  // ===========================================================

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.image != null)
            Image(
              image: widget.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            )
          else
            _imagePlaceholder(),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: _roundIconButton(
              icon: Icons.arrow_forward,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),

          // زرار تعديل مواعيد التطعيمات
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _roundIconButton(
              icon: Icons.edit_outlined,
              onTap: _openEditDates,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _kGreenLight,
      child: const Icon(
        Icons.pets,
        size: 80,
        color: _kGreen,
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xE6FFFFFF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: _kDark),
        ),
      ),
    );
  }

  // ===========================================================
  // كروت العمر والوزن (بتظهر بس لو البيانات موجودة)
  // ===========================================================

  /// العمر مش بيظهر للماعز والخروف (مبيتسجلش لهم عمر)
  String? get _ageText {
    if (_isLivestock) return null;
    return _ageTextFrom(_animal.ageYears, _animal.ageMonths, _animal.ageDays);
  }

  String? get _weightText =>
      _weightTextFrom(_animal.weightKg, _animal.weightGrams);

  List<Widget> _buildStatsSection() {
    final cards = <Widget>[];

    final age = _ageText;
    if (age != null) {
      cards.add(
        _buildStatCard(
          icon: Icons.calendar_today_outlined,
          label: 'العمر',
          value: age,
        ),
      );
    }

    final weight = _weightText;
    if (weight != null) {
      cards.add(
        _buildStatCard(
          icon: Icons.monitor_weight_outlined,
          label: 'الوزن',
          value: weight,
        ),
      );
    }

    if (cards.isEmpty) return const <Widget>[];

    final children = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 12));
      children.add(Expanded(child: cards[i]));
    }

    return [
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: children),
      ),
    ];
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGreen, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _kGrey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kDark,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // التابات
  // ===========================================================

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _buildTabItem(_PetTab.info, 'المعلومات'),
          _buildTabItem(_PetTab.vaccinations, 'التحصينات'),
          _buildTabItem(_PetTab.records, 'السجل الطبي'),
        ],
      ),
    );
  }

  Widget _buildTabItem(_PetTab tab, String title) {
    final bool selected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _kGreenLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? _kGreen : _kGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case _PetTab.info:
        return _buildInfoTab();
      case _PetTab.vaccinations:
        return _buildVaccinationsTab();
      case _PetTab.records:
        return _buildNote('السجل الطبي سيظهر هنا.');
    }
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: _kGrey),
        ),
      ),
    );
  }

  // ===========================================================
  // تاب المعلومات (البيانات اللي اتدخلت بس)
  // ===========================================================

  Widget _buildInfoTab() {
    final rows = <Widget>[
      _infoRow('الاسم', _animal.name),
    ];

    final category = _categoryLabel(_animal.category);
    if (category != null) rows.add(_infoRow('النوع', category));

    rows.add(_infoRow('السلالة / الجنس', _breedAndGender()));

    final age = _ageText;
    if (age != null) rows.add(_infoRow('العمر', age));

    final weight = _weightText;
    if (weight != null) rows.add(_infoRow('الوزن', weight));

    return Column(children: rows);
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _kGrey),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // تاب التحصينات
  // ===========================================================

  Widget _buildVaccinationsTab() {
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final effective = _effectiveAnimal();
    final schedule = _computeSchedule(effective);

    if (schedule.isEmpty) {
      return _buildNote('لا توجد تطعيمات مستحقة حالياً.');
    }

    return Column(
      children: [
        for (final item in schedule) ...[
          _buildVaccineCard(item, effective),
          const SizedBox(height: 12),
        ],

        // ملاحظة الفاصل بين التطعيمات (الماعز والخروف)
        if (_isLivestock)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'ملاحظة: يجب أن يكون بين كل تطعيم والتطعيم الذي يليه 15 يوماً على الأقل.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _kGrey),
            ),
          ),
      ],
    );
  }

  Widget _buildVaccineCard(VaccinationModel item, AnimalModel effective) {
    final today = _dateOnly(DateTime.now());
    final due = _dateOnly(item.dueDate);
    final daysLeft = _daysBetween(today, due);

    final bool isToday = daysLeft == 0;
    final bool isOverdue = daysLeft < 0;
    final bool isDue = isToday || isOverdue;

    final last = _lastOfTrack(effective, _trackKeyOf(item.id));

    // ألوان الكارت حسب الحالة
    final Color cardBg = isOverdue
        ? _kRedBg
        : isToday
        ? _kAmberBg
        : Colors.white;

    final Color borderColor = isOverdue
        ? _kRed
        : isToday
        ? _kAmber
        : _kBorder;

    final Color chipBg = isOverdue
        ? _kRedChip
        : isToday
        ? _kAmberChip
        : _kGreenLight;

    final Color chipFg = isOverdue
        ? _kRed
        : isToday
        ? _kAmber
        : _kGreen;

    // نص العد التنازلي (على الجنب)
    final String chipLabel;
    final String chipValue;

    if (isToday) {
      chipLabel = '';
      chipValue = 'اليوم';
    } else if (isOverdue) {
      chipLabel = 'متأخر منذ';
      chipValue = _spanText(_span(due, today));
    } else {
      chipLabel = 'متبقي';
      chipValue = _spanText(_span(today, due));
    }

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(item, effective),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.vaccineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'الموعد: ${_formatDate(due)}',
                      style: const TextStyle(fontSize: 12, color: _kGrey),
                    ),

                    if (last != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'آخر جرعة: ${_formatDate(last)}',
                        style: const TextStyle(fontSize: 11, color: _kGrey),
                      ),
                    ],

                    if (isDue) ...[
                      const SizedBox(height: 8),
                      Text(
                        isToday
                            ? 'حان موعد التطعيم اليوم'
                            : 'فات موعد التطعيم',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: chipFg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'اضغط لعرض التفاصيل وتسجيل التطعيم',
                        style: TextStyle(fontSize: 11, color: _kGrey),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 108),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chipLabel.isNotEmpty)
                        Text(
                          chipLabel,
                          style: TextStyle(fontSize: 10, color: chipFg),
                        ),
                      Text(
                        chipValue,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: chipFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}