import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

/// تخزين صور الحيوانات محليًا في Hive.
///
/// المفتاح  = Firestore document ID بتاع الحيوان (pet.id)
/// القيمة   = بايتات الصورة (Uint8List)
///
/// الصورة بتتخزن على الجهاز بس (مش في Firestore).
class PetImageLocalStorage {
  PetImageLocalStorage._();

  static final PetImageLocalStorage instance = PetImageLocalStorage._();

  static const String _boxName = 'pet_images';

  static bool _hiveReady = false;
  Box<Uint8List>? _box;

  /// آمن تناديه أكتر من مرة.
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;

    if (!_hiveReady) {
      await Hive.initFlutter();
      _hiveReady = true;
    }

    _box = await Hive.openBox<Uint8List>(_boxName);
  }

  /// حفظ صورة الحيوان
  Future<void> saveImage(String petId, Uint8List bytes) async {
    await init();
    await _box!.put(petId, bytes);
  }

  /// قراءة الصورة (synchronous بعد ما يتم init)
  /// بترجع null لو الحيوان ملوش صورة.
  Uint8List? getImage(String petId) {
    return _box?.get(petId);
  }

  /// حذف صورة الحيوان (استخدميها لما تمسحي الحيوان)
  Future<void> deleteImage(String petId) async {
    await init();
    await _box!.delete(petId);
  }
}