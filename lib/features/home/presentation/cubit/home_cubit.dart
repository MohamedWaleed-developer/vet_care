import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pets/data/local/pet_image_local_storage.dart';
import '../../../pets/data/repositories/pets_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseAuth _auth;
  final PetsRepository _petsRepository;
  final PetImageLocalStorage _petImageStorage;

  HomeCubit(this._auth, this._petsRepository, this._petImageStorage)
    : super(
        HomeState(
          userName: _auth.currentUser?.displayName?.trim() ?? '',
          userEmail: _auth.currentUser?.email,
          photoUrl: _auth.currentUser?.photoURL,
        ),
      );

  Future<void> loadPets() async {
    emit(state.copyWith(isLoadingPets: true, clearError: true));
    final user = _auth.currentUser;

    if (user == null) {
      emit(
        state.copyWith(
          pets: const [],
          petImages: const {},
          isLoadingPets: false,
        ),
      );
      return;
    }

    try {
      await _petImageStorage.init();
      final pets = await _petsRepository.getPets(user.uid);
      final images = {
        for (final pet in pets) pet.id: _petImageStorage.getImage(pet.id),
      };

      emit(state.copyWith(pets: pets, petImages: images, isLoadingPets: false));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingPets: false,
          errorMessage: 'تعذر تحميل بيانات حيواناتك الأليفة.',
        ),
      );
    }
  }
}
