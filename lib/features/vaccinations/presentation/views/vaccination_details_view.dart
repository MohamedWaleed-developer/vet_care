import 'package:flutter/material.dart';

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

const _kRed = Color(0xFFC84A4A);
const _kRedBg = Color(0xFFFFE7E7);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// شاشة تفاصيل اللقاح.
///
/// بتتفتح لما المستخدم يدوس على تطعيم في تاب التحصينات.
/// الزرار اللي تحت بيسجل إن الحيوان اتطعّم، وبعدها الشاشة بتقفل.
class VaccinationDetailsView extends StatefulWidget {
  final String vaccineName;

  /// معلومات عن اللقاح
  final String description;

  /// موعد الجرعة القادمة
  final DateTime dueDate;

  /// تاريخ آخر جرعة (لو معروف)
  final DateTime? lastDate;

  final String petName;

  /// مثال: 'شيرازي · أنثى'
  final String? petSubtitle;

  final ImageProvider? petImage;

  /// بتحوّل التاريخ لنص، مثال: '15 فبراير 2027'
  final String Function(DateTime date) formatDate;

  /// بتكتب الوقت المتبقي أو المتأخر، مثال: 'متبقي شهرين و 5 أيام'
  final String Function(DateTime due) countdownText;

  /// بتسجل إن الحيوان اتطعّم
  final Future<void> Function() onMarkGiven;

  /// بتحفظ الموعد الجديد لو المستخدم عدّله
  final Future<void> Function(DateTime newDate) onChangeDate;

  const VaccinationDetailsView({
    super.key,
    required this.vaccineName,
    required this.description,
    required this.dueDate,
    required this.petName,
    required this.formatDate,
    required this.countdownText,
    required this.onMarkGiven,
    required this.onChangeDate,
    this.lastDate,
    this.petSubtitle,
    this.petImage,
  });

  @override
  State<VaccinationDetailsView> createState() => _VaccinationDetailsViewState();
}

class _VaccinationDetailsViewState extends State<VaccinationDetailsView> {
  late DateTime _due;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _due = _dateOnly(widget.dueDate);
  }

  Future<void> _markGiven() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await widget.onMarkGiven();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeDate() async {
    final today = _dateOnly(DateTime.now());
    final first = DateTime(today.year - 1, today.month, today.day);
    final last = DateTime(today.year + 3, today.month, today.day);

    DateTime initial = _due;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'اختر موعد التطعيم',
    );

    if (picked == null || !mounted) return;

    final newDate = _dateOnly(picked);
    await widget.onChangeDate(newDate);

    if (!mounted) return;
    setState(() => _due = newDate);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final bool isToday = _due == today;
    final bool isOverdue = _due.isBefore(today);

    final String statusText = isOverdue
        ? 'فات موعده'
        : isToday
        ? 'حان موعده اليوم'
        : 'قادم';

    final Color statusBg = isOverdue
        ? _kRedBg
        : isToday
        ? _kAmberBg
        : _kGreenLight;

    final Color statusFg = isOverdue
        ? _kRed
        : isToday
        ? _kAmber
        : _kGreen;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _kBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(statusText, statusBg, statusFg),

                      const SizedBox(height: 24),

                      const Text(
                        'سجل الجرعات والجدول الزمني',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildTimelineCard(statusFg),

                      const SizedBox(height: 16),

                      _buildPetCard(),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // الشريط العلوي
  // ===========================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: _kBorder),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.arrow_forward, size: 20, color: _kDark),
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'تفاصيل اللقاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kDark,
              ),
            ),
          ),

          // نفس عرض الزرار عشان العنوان يفضل في النص
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ===========================================================
  // كارت معلومات اللقاح
  // ===========================================================

  Widget _buildInfoCard(String statusText, Color statusBg, Color statusFg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.vaccineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kDark,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _kGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // الجدول الزمني (الجرعة القادمة + الجرعة السابقة)
  // ===========================================================

  Widget _buildTimelineCard(Color accent) {
    final last = widget.lastDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          _timelineRow(
            dotColor: _kGreen,
            showLine: last != null,
            title: 'الجرعة القادمة المستحقة',
            titleColor: _kGreen,
            lines: [
              'تاريخ: ${widget.formatDate(_due)}',
              widget.countdownText(_due),
            ],
            action: TextButton.icon(
              onPressed: _saving ? null : _changeDate,
              icon: const Icon(Icons.edit_calendar_outlined, size: 16),
              label: const Text('تعديل الموعد'),
              style: TextButton.styleFrom(
                foregroundColor: _kGreen,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          if (last != null)
            _timelineRow(
              dotColor: _kBorder,
              showLine: false,
              title: 'الجرعة السابقة',
              titleColor: _kDark,
              lines: ['تاريخ: ${widget.formatDate(last)}'],
            ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required Color dotColor,
    required bool showLine,
    required String title,
    required Color titleColor,
    required List<String> lines,
    Widget? action,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _kBorder,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 18 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),

                  for (final line in lines) ...[
                    const SizedBox(height: 4),
                    Text(
                      line,
                      style: const TextStyle(fontSize: 12, color: _kGrey),
                    ),
                  ],

                  if (action != null) ...[
                    const SizedBox(height: 4),
                    action,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // كارت الحيوان
  // ===========================================================

  Widget _buildPetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 52,
              height: 52,
              child: widget.petImage != null
                  ? Image(
                image: widget.petImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _petPlaceholder(),
              )
                  : _petPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.petName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kDark,
                  ),
                ),

                if (widget.petSubtitle != null &&
                    widget.petSubtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.petSubtitle!,
                    style: const TextStyle(fontSize: 12, color: _kGrey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _petPlaceholder() {
    return Container(
      color: _kGreenLight,
      child: const Icon(Icons.pets, color: _kGreen, size: 26),
    );
  }

  // ===========================================================
  // الزرار اللي تحت: تسجيل إن الحيوان اتطعّم
  // ===========================================================

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: _kBackground,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _markGiven,
          icon: _saving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.check_circle_outline),
          label: const Text('تم تطعيم الحيوان'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kGreen.withAlpha(150),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}