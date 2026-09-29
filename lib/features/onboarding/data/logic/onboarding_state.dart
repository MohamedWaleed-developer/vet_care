abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingPageChangedState extends OnboardingState {
  final int index;
  OnboardingPageChangedState(this.index);
}