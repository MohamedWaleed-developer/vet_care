import '../../data/models/profile_model.dart';

enum ProfileStatus { initial, loading, loaded, saving, saved, failure }

class ProfileState {
  final ProfileStatus status;
  final ProfileModel? profile;
  final String? errorMessage;
  final bool emailVerificationSent;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.emailVerificationSent = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorMessage,
    bool? emailVerificationSent,
    bool clearError = false,
  }) =>
      ProfileState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        emailVerificationSent:
            emailVerificationSent ?? this.emailVerificationSent,
      );
}
