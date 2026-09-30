import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/screens/login_screen.dart';

/// المسار:
/// lib/features/splash/presentation/screens/splash_screen.dart

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _bg = Color(0xFFE7E6DF);
  static const Color _green = Color(0xFF1F7060);

  /// صورة الـ Splash
  static const String _imagePath =
      'assets/images/splash_image.png';

  /// حجم الصورة
  static const double _logoWidthFactor = 0.9;
  static const double _logoMaxWidth = 420;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // =========================
            // الدوائر الزخرفية في الخلفية
            // =========================

            _bgCircle(
              left: -w * 0.30,
              top: -h * 0.02,
              size: w * 0.78,
              color: const Color(0xFFE2E2DA),
            ),

            _bgCircle(
              right: -w * 0.50,
              top: h * 0.30,
              size: w * 0.75,
              color: const Color(0xFFE1E4DB),
            ),

            _bgCircle(
              left: -w * 0.30,
              bottom: -h * 0.06,
              size: w * 0.62,
              color: const Color(0xFFC7CEBF),
            ),

            _bgCircle(
              right: -w * 0.32,
              bottom: -h * 0.08,
              size: w * 0.55,
              color: const Color(0xFFE0E3DA),
            ),

            // =========================
            // محتوى الشاشة
            // =========================

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 9),

                    // =========================
                    // صورة الـ Splash
                    // =========================

                    Image.asset(
                      _imagePath,
                      width: (w * _logoWidthFactor)
                          .clamp(0.0, _logoMaxWidth),
                      fit: BoxFit.contain,
                    ),

                    const Spacer(flex: 8),

                    // =========================
                    // اسم التطبيق
                    // =========================

                    Text(
                      'سكة العلاج البيطرية',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _green,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================
                    // وصف التطبيق
                    // =========================

                    Text(
                      'كل ما تحتاجه لرعاية حيوانك..\n'
                          'في مكان واحد',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: _green,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 9),

                    // =========================
                    // زر ابدأ
                    // =========================

                    _StartButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // الدوائر الخلفية
  // =========================

  Widget _bgCircle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// =======================
// زرار ابدأ
// =======================

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: Material(
        color: const Color(0xFF1F7060),
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.green.shade600,
            width: 1,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'ابدأ',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const Positioned(
                right: 26,
                child: Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}