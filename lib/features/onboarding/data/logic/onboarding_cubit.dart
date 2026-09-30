import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void navigateToAuth(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'الانتقال إلى شاشة تسجيل الدخول / إنشاء الحساب',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}