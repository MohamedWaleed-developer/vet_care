import 'dart:typed_data';

import '../../../pets/data/models/animal_model.dart';

class HomeState {
  final String userName;
  final String? userEmail;
  final String? photoUrl;
  final List<AnimalModel> pets;
  final Map<String, Uint8List?> petImages;
  final bool isLoadingPets;
  final String? errorMessage;

  const HomeState({
    this.userName = '',
    this.userEmail,
    this.photoUrl,
    this.pets = const [],
    this.petImages = const {},
    this.isLoadingPets = true,
    this.errorMessage,
  });

  HomeState copyWith({
    String? userName,
    String? userEmail,
    bool clearUserEmail = false,
    String? photoUrl,
    bool clearPhotoUrl = false,
    List<AnimalModel>? pets,
    Map<String, Uint8List?>? petImages,
    bool? isLoadingPets,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      userEmail: clearUserEmail ? null : userEmail ?? this.userEmail,
      photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,
      pets: pets ?? this.pets,
      petImages: petImages ?? this.petImages,
      isLoadingPets: isLoadingPets ?? this.isLoadingPets,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
