import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/logic/onboarding_cubit.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingBottomActions extends StatelessWidget {
  const OnboardingBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1F604D);
    final cubit = context.read<OnboardingCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Smooth Indicator Package replacing manual loops
          SmoothPageIndicator(
            controller: cubit.pageController,
            count: OnboardingModel.pages.length,
            effect: const ExpandingDotsEffect(
              activeDotColor: primaryColor,
              dotColor: Color(0xFFD2DCD7),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 8,
            ),
          ),
          const SizedBox(height: 28),

          // Dynamic Buttons
          if (cubit.currentIndex < OnboardingModel.pages.length - 1) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => cubit.nextPage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'التالي ›',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => cubit.navigateToAuth(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ابدأ الآن',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🐾', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => cubit.navigateToAuth(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F7F5),
                  side: const BorderSide(color: primaryColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'لدي حساب – سجّل الدخول',
                  style: GoogleFonts.cairo(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}