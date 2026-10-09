import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// اختيار صورة الحيوان (اختياري).
/// بيرجّع بايتات الصورة عن طريق [onChanged] (null = مفيش صورة).
class PetImagePicker extends StatefulWidget {
  final ValueChanged<Uint8List?> onChanged;

  const PetImagePicker({super.key, required this.onChanged});

  @override
  State<PetImagePicker> createState() => _PetImagePickerState();
}

class _PetImagePickerState extends State<PetImagePicker> {
  static const Color _green = Color(0xFF168052);

  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800, // تصغير الصورة عشان متاخدش مساحة كبيرة
        maxHeight: 800,
        imageQuality: 80,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;
      setState(() => _bytes = bytes);
      widget.onChanged(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر اختيار الصورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _remove() {
    setState(() => _bytes = null);
    widget.onChanged(null);
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: _green),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                const Icon(Icons.photo_camera_outlined, color: _green),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(ImageSource.camera);
                },
              ),
              if (_bytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  title: const Text('إزالة الصورة'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _remove();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSourceSheet,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD6E4DC),
                    width: 1.5,
                  ),
                  image: _bytes == null
                      ? null
                      : DecorationImage(
                    image: MemoryImage(_bytes!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _bytes == null
                    ? const Icon(
                  Icons.pets,
                  size: 42,
                  color: Color(0xFF8AA79A),
                )
                    : null,
              ),

              // أيقونة الكاميرا
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _bytes == null ? 'أضف صورة (إختياري)' : 'تغيير الصورة',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7A8A84),
            ),
          ),
        ],
      ),
    );
  }
}