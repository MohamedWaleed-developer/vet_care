import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _bg = Color(0xFFE7E6DF);
  static const Color _green = Color(0xFF1F7060);

  static const String _imagePath = 'assets/images/splash_image.png';
  static const double _logoWidthFactor = 0.9;
  static const double _logoMaxWidth = 420;

  Future<void> _navigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!context.mounted) return;

    Widget next;

    if (user != null) {
      try {
        final tokenResult = await user.getIdTokenResult(true);
        final isAdmin = tokenResult.claims?['admin'] == true;

        if (!context.mounted) return;

        next = isAdmin ? const AdminDashboardScreen() : const HomeScreen();
      } catch (_) {
        if (!context.mounted) return;

        next = const HomeScreen();
      }
    } else if (!seenOnboarding) {
      next = const OnboardingScreen();
    } else {
      next = const OnboardingScreen();
    }

    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = (constraints.maxWidth * _logoWidthFactor).clamp(
              0.0,
              _logoMaxWidth,
            );

            return Column(
              children: [
                const Spacer(),
                Center(
                  child: Image.asset(
                    _imagePath,
                    width: logoWidth,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Icon(Icons.pets_rounded, size: 100, color: _green);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vet Care',
                  style: GoogleFonts.cairo(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'رعاية أفضل لحيواناتك',
                  style: GoogleFonts.cairo(fontSize: 16, color: _green),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _navigate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'ابدأ',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
