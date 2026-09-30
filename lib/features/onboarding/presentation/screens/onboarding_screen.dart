import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/logic/onboarding_cubit.dart';
import '../../data/logic/onboarding_state.dart';
import '../../data/models/onboarding_model.dart';
import '../widgets/onboarding_bottom_actions.dart';
import '../widgets/onboarding_page_item.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                final cubit = context.read<OnboardingCubit>();
                final isLastPage = cubit.currentIndex == OnboardingModel.pages.length - 1;

                return Column(
                  children: [
                    // Top Bar Skip Action
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48),
                          AnimatedOpacity(
                            opacity: isLastPage ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: TextButton(
                              onPressed: isLastPage ? null : cubit.skipPage,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF8E8E93),
                                textStyle: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('تخطي'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Page Carousel
                    Expanded(
                      child: PageView.builder(
                        controller: cubit.pageController,
                        itemCount: OnboardingModel.pages.length,
                        onPageChanged: cubit.onPageChanged,
                        itemBuilder: (context, index) {
                          return OnboardingPageItem(
                            item: OnboardingModel.pages[index],
                          );
                        },
                      ),
                    ),

                    // Bottom Actions Section
                    const OnboardingBottomActions(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}