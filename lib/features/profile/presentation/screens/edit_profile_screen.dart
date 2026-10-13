import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  Uint8List? _selectedPhotoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.saved && state.profile != null) {
              Navigator.of(context).pop(state.emailVerificationSent);
            } else if (state.status == ProfileStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final isSaving = state.status == ProfileStatus.saving;
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                backgroundColor: const Color(0xFFF8F9FA),
                elevation: 0,
                centerTitle: true,
                leadingWidth: 64,
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'رجوع',
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                title: const Text(
                  'تعديل الملف الشخصي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Center(child: _photoEditor()),
                              const SizedBox(height: 24),
                              const Text(
                                'المعلومات الشخصية',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldLabel('الاسم الكامل'),
                              const SizedBox(height: 6),
                              _textField(
                                controller: _nameController,
                                hintText: 'أدخل اسمك بالكامل',
                                validator: (value) => value == null ||
                                        value.trim().isEmpty
                                    ? 'اكتب الاسم الكامل.'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _fieldLabel('البريد الإلكتروني'),
                              const SizedBox(height: 6),
                              _textField(
                                controller: _emailController,
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 16),
                              _fieldLabel('رقم الجوال'),
                              const SizedBox(height: 6),
                              _textField(
                                controller: _phoneController,
                                hintText: '+20 1X XXX XXXX',
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'سيُحفظ الرقم كبيانات تواصل في حسابك.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _privacyNotice(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E6554),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'حفظ التغييرات',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _photoEditor() {
    final imageBytes = _selectedPhotoBytes ?? widget.profile.photoBytes;
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E6554), width: 2),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFE6F3EF),
                backgroundImage:
                    imageBytes == null ? null : MemoryImage(imageBytes),
                child: imageBytes == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        size: 46,
                        color: Color(0xFF1E6554),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 2,
              left: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E6554),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _pickPhoto,
          child: Text(
            'تغيير الصورة الشخصية',
            style: const TextStyle(
              color: Color(0xFF1E6554),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 480,
      maxHeight: 480,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 512 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري صورة حجمها أقل من 500 كيلوبايت.')),
      );
      return;
    }
    setState(() => _selectedPhotoBytes = bytes);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          originalEmail: widget.profile.email,
          photoBytes: _selectedPhotoBytes,
        );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'اكتب البريد الإلكتروني.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'تحقق من صيغة البريد الإلكتروني.';
    }
    return null;
  }

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    String? Function(String?)? validator,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
          ),
        ),
      );

  Widget _privacyNotice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F3EF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primaryDark, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'نستخدم بياناتك لتحديث طلباتك ومواعيد رعاية أليفك، ونحافظ على خصوصيتها.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1E6554),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}
