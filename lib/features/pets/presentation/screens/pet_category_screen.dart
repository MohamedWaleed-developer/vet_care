import 'package:flutter/material.dart';

import '../../data/models/animal_model.dart';
import 'add_pet_prompt_screen.dart' show PawPainter;
import 'add_pet_screen.dart';

/// شاشة: "ما نوع حيوانك؟"
/// حيوان أليف  -> (كلب / قطة)
/// حيوان مزرعة -> (أغنام / ماعز)
class PetCategoryScreen extends StatelessWidget {
  const PetCategoryScreen({super.key});

  static const Color _bg = Color(0xFFE8E8E0);
  static const Color _darkGreen = Color(0xFF1F6F5C);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ---------- الدوائر الخلفية ----------
          Positioned(
            top: -size.width * 0.35,
            left: -size.width * 0.45,
            child: _circle(size.width * 0.95, const Color(0xFFE2E4DB)),
          ),
          Positioned(
            top: size.height * 0.30,
            right: -size.width * 0.55,
            child: _circle(size.width * 0.85, const Color(0xFFE0E5DC)),
          ),
          Positioned(
            bottom: -size.width * 0.30,
            left: -size.width * 0.25,
            child: _circle(size.width * 0.70, const Color(0xFFC9CFBE)),
          ),
          Positioned(
            bottom: -size.width * 0.35,
            right: -size.width * 0.30,
            child: _circle(size.width * 0.75, const Color(0xFFE0E5DC)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  const SizedBox(
                    width: 230,
                    height: 230,
                    child: CustomPaint(painter: PawPainter()),
                  ),

                  const Spacer(flex: 2),

                  const Text(
                    'ما نوع حيوانك؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _darkGreen,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // أول عنصر يظهر على اليمين (RTL)
                  Row(
                    children: [
                      Expanded(
                        child: _MainTypeCard(
                          title: 'حيوان أليف',
                          icon: Icons.pets,
                          filled: true,
                          onTap: () => _showCompanionSheet(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MainTypeCard(
                          title: 'حيوان مزرعة',
                          icon: Icons.agriculture,
                          filled: false,
                          onTap: () => _showFarmSheet(context),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),

          // ---------- زر الرجوع (أعلى اليمين في RTL) ----------
          PositionedDirectional(
            top: 0,
            start: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 22,
                    color: _darkGreen,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Bottom sheets
  // =========================================================
  void _showCompanionSheet(BuildContext context) {
    _showTypeSheet(
      context,
      title: 'اختر نوع حيوانك الأليف',
      subtitle: 'يمكنك إختيار إما قطة أو كلب',
      options: const [
        _PetOption('كلب', 'assets/images/dog.png', PetCategory.dog),
        _PetOption('قطة', 'assets/images/cat.png', PetCategory.cat),
      ],
    );
  }

  void _showFarmSheet(BuildContext context) {
    _showTypeSheet(
      context,
      title: 'اختر نوع حيوان المزرعة',
      subtitle: 'يمكنك إختيار إما خروف أو ماعز',
      options: const [
        _PetOption('أغنام', 'assets/images/sheep.png', PetCategory.sheep),
        _PetOption('ماعز', 'assets/images/goat.png', PetCategory.goat),
      ],
    );
  }

  void _showTypeSheet(
      BuildContext context, {
        required String title,
        required String subtitle,
        required List<_PetOption> options,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // المقبض
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFC5C2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5E9A89),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: _PetOptionCard(
                          option: options[i],
                          onTap: () {
                            Navigator.pop(sheetContext); // قفل الـ sheet
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddPetScreen(
                                  category: options[i].category,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// =============================================================
// بيانات الاختيار
// =============================================================
class _PetOption {
  final String label;
  final String asset;
  final PetCategory category;

  const _PetOption(this.label, this.asset, this.category);
}

// =============================================================
// كارت (حيوان أليف / حيوان مزرعة)
// =============================================================
class _MainTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _MainTypeCard({
    required this.title,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1F6F5C);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: filled ? green : const Color(0xFFF4FBF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? const Color(0xFF0F4A3C) : green,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : green,
              ),
            ),
            const SizedBox(height: 12),
            Icon(icon, size: 26, color: filled ? Colors.white : green),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// كارت الحيوان داخل الـ bottom sheet
// =============================================================
class _PetOptionCard extends StatelessWidget {
  final _PetOption option;
  final VoidCallback onTap;

  const _PetOptionCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1F6F5C);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF7FAA9C), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Image.asset(
                option.asset,
                fit: BoxFit.contain,
                // لو الصورة مش موجودة لسه
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.pets,
                  size: 64,
                  color: Color(0xFF7FAA9C),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}