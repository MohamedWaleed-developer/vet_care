import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/screens/login_screen.dart';

import '../models/onboarding_model.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  final PageController pageController = PageController();
  int currentIndex = 0;

  void onPageChanged(int index) {
    currentIndex = index;
    emit(OnboardingPageChangedState(index));
  }

  void nextPage(BuildContext context) {
    if (currentIndex < OnboardingModel.pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      navigateToAuth(context);
    }
  }

  void skipPage() {
    pageController.animateToPage(
      OnboardingModel.pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> navigateToAuth(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}