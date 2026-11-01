import 'dart:typed_data';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../../../pets/data/models/animal_model.dart';
import 'my_pets_section.dart';

class HomePetsSection extends StatelessWidget {
  final bool isLoading;
  final List<AnimalModel> pets;
  final Map<String, Uint8List?> petImages;
  final VoidCallback onAddTap;
  final VoidCallback onViewAllTap;
  final ValueChanged<AnimalModel> onPetTap;

  const HomePetsSection({
    super.key,
    required this.isLoading,
    required this.pets,
    required this.petImages,
    required this.onAddTap,
    required this.onViewAllTap,
    required this.onPetTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: MyPetsSection(
        showHeader: false,
        pets: pets,
        onAddTap: onAddTap,
        onViewAllTap: onViewAllTap,
        onPetTap: onPetTap,
        imageBuilder: (pet) {
          final bytes = petImages[pet.id];
          return bytes == null ? null : MemoryImage(bytes);
        },
      ),
    );
  }
}
