import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../../../pets/data/models/animal_model.dart';
import '../home_colors.dart';

/// قسم "حيواناتي":
///  - أول كارت (يمين) = زر + لإضافة حيوان جديد
///  - بعده كروت الحيوانات المضافة
///  - لو الحيوان له صورة بتظهر، وإلا بتظهر أيقونة حسب نوعه (🐱 🐶 🐐 🐑)
class MyPetsSection extends StatelessWidget {
  final List<AnimalModel> pets;

  /// الضغط على كارت (+)
  final VoidCallback? onAddTap;

  final VoidCallback? onViewAllTap;
  final ValueChanged<AnimalModel>? onPetTap;

  /// لو عندك صورة محفوظة للحيوان (Hive / ملف / URL) رجّعيها هنا.
  /// لو رجعت null بتظهر الأيقونة الافتراضية.
  /// مثال: (pet) => FileImage(File(path))
  final ImageProvider? Function(AnimalModel pet)? imageBuilder;

  /// false لو الهيدر (حيواناتي / عرض الكل) متعمل برّه
  final bool showHeader;

  const MyPetsSection({
    super.key,
    required this.pets,
    this.onAddTap,
    this.onViewAllTap,
    this.onPetTap,
    this.imageBuilder,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.pets, size: 18, color: HomeColors.green),
                  SizedBox(width: 6),
                  Text(
                    'حيواناتي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: HomeColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          height: 235,
          // السماح بالسحب بالـ touch والماوس والـ trackpad (مهم للـ emulator والويب)
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // يفضل السكرول شغال حتى لو الكروت قليلة
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              // +1 لكارت الإضافة
              itemCount: pets.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                // أول عنصر (يمين في RTL) = زر الإضافة
                if (index == 0) {
                  return _AddPetCard(onTap: onAddTap);
                }

                final pet = pets[index - 1];
                return _PetCard(
                  pet: pet,
                  image: imageBuilder?.call(pet),
                  onTap: onPetTap == null ? null : () => onPetTap!(pet),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// كارت الإضافة (+)
// =============================================================
class _AddPetCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddPetCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: HomeColors.cardBorder,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: HomeColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 34, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text(
              'إضافة حيوان\nجديد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.bold,
                color: HomeColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// كارت الحيوان
// =============================================================
class _PetCard extends StatelessWidget {
  final AnimalModel pet;
  final ImageProvider? image;
  final VoidCallback? onTap;

  const _PetCard({required this.pet, this.image, this.onTap});

  static const _months = [
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

  String get _categoryLabel {
    switch (pet.category) {
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

  /// الأيقونة الافتراضية حسب نوع الحيوان
  String get _emoji {
    switch (pet.category) {
      case PetCategory.cat:
        return '🐱';
      case PetCategory.dog:
        return '🐶';
      case PetCategory.goat:
        return '🐐';
      case PetCategory.sheep:
        return '🐑';
    }
  }

  /// "3 سنوات" / "5 شهور" / "10 أيام" (أو مجموعة منهم)
  String get _ageText {
    final parts = <String>[];

    if (pet.ageYears > 0) {
      parts.add(pet.ageYears == 1
          ? 'سنة'
          : pet.ageYears == 2
          ? 'سنتان'
          : '${pet.ageYears} ${pet.ageYears <= 10 ? 'سنوات' : 'سنة'}');
    }
    if (pet.ageMonths > 0) {
      parts.add('${pet.ageMonths} ${pet.ageMonths <= 10 ? 'شهور' : 'شهر'}');
    }
    if (pet.ageDays > 0) {
      parts.add('${pet.ageDays} ${pet.ageDays <= 10 ? 'أيام' : 'يوم'}');
    }

    // الماعز والخروف مش بيتسجل لهم عمر -> نرجّع نص فاضي
    return parts.join(' و ');
  }

  /// أحدث تاريخ تطعيم مسجل (لو فيه)
  DateTime? get _lastVaccineDate {
    final dates = <DateTime>[
      if (pet.lastRabiesDate != null) pet.lastRabiesDate!,
      if (pet.lastCoreDate != null) pet.lastCoreDate!,
      if (pet.lastSmallpoxDate != null) pet.lastSmallpoxDate!,
      if (pet.lastFmdDate != null) pet.lastFmdDate!,
      if (pet.lastMycoDate != null) pet.lastMycoDate!,
    ];
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final lastVaccine = _lastVaccineDate;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: HomeColors.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomeColors.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            // صورة الحيوان أو أيقونة حسب نوعه
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFDDEAE3),
              backgroundImage: image,
              child: image == null
                  ? Text(_emoji, style: const TextStyle(fontSize: 48))
                  : null,
            ),

            const SizedBox(height: 14),

            Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: HomeColors.green,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _ageText.isEmpty ? _categoryLabel : '$_categoryLabel - $_ageText',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: HomeColors.subtitle,
              ),
            ),

            if (lastVaccine != null) ...[
              const SizedBox(height: 6),
              Text(
                _formatDate(lastVaccine),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HomeColors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}