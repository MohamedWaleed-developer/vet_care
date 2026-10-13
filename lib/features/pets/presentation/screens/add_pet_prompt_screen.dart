import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_screen.dart';
import 'pet_category_screen.dart';

/// شاشة: "هل تود إضافة بيانات حيوانك؟"
///
/// - زر "نعم"      -> يفتح PetCategoryScreen (اختيار نوع الحيوان)
///                   ثم AddPetScreen حسب النوع المختار.
/// - زر "ليس الآن"  -> يفتح HomeScreen
class AddPetPromptScreen extends StatelessWidget {
  const AddPetPromptScreen({super.key});

  static const Color _bg = Color(0xFFE8E8E0);
  static const Color _darkGreen = Color(0xFF1F6F5C);
  static const Color _borderGreen = Color(0xFF4CAF7A);

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

          // ---------- المحتوى ----------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // الأيقونة
                  const SizedBox(
                    width: 230,
                    height: 230,
                    child: CustomPaint(painter: PawPainter()),
                  ),

                  const Spacer(flex: 2),

                  // السؤال
                  const Text(
                    'هل تود إضافة بيانات\nحيوانك؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                      color: _darkGreen,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر نعم
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PetCategoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: _borderGreen),
                        ),
                      ),
                      child: const Text(
                        'نعم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر ليس الآن
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E4DC),
                        foregroundColor: _darkGreen,
                        side: const BorderSide(color: _borderGreen),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ليس الآن',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
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
// رسم بصمة القدم
// =============================================================
class PawPainter extends CustomPainter {
  const PawPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // الرسم متصمم على مساحة 300x300 ثم بيتم تصغيره
    canvas.scale(size.width / 300, size.height / 300);

    final white = Paint()..color = const Color(0xFFFAFAFA);
    final glow = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // الأصابع (center, width, height)
    final toes = <Rect>[
      Rect.fromCenter(center: const Offset(40, 115), width: 68, height: 86),
      Rect.fromCenter(center: const Offset(109, 58), width: 68, height: 88),
      Rect.fromCenter(center: const Offset(186, 58), width: 68, height: 88),
      Rect.fromCenter(center: const Offset(256, 115), width: 68, height: 86),
    ];

    for (final r in toes) {
      canvas.drawOval(r.inflate(5), glow);
    }
    for (final r in toes) {
      canvas.drawOval(r, white);
    }

    // الوسادة الكبيرة (هلال)
    final pad = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(147, 215),
        width: 146,
        height: 122,
      ));
    final notch = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(147, 182),
        width: 96,
        height: 96,
      ));
    final crescent = Path.combine(PathOperation.difference, pad, notch);

    canvas.drawPath(crescent, glow);
    canvas.drawPath(crescent, white);

    // القطرة الخضراء
    final drop = Path()
      ..moveTo(147, 128)
      ..cubicTo(130, 148, 124, 160, 124, 170)
      ..cubicTo(124, 183, 134, 190, 147, 190)
      ..cubicTo(160, 190, 170, 183, 170, 170)
      ..cubicTo(170, 160, 164, 148, 147, 128)
      ..close();

    canvas.drawPath(drop, Paint()..color = const Color(0xFF4DB38E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}