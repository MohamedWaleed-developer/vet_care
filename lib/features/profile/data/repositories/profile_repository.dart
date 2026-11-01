import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository(this._remoteDataSource);

  Future<ProfileModel> getProfile() => _remoteDataSource.getProfile();

  Future<ProfileModel> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? photoBase64,
  }) =>
      _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        photoBase64: photoBase64,
      );
}
