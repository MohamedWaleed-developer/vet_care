import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../data/local/pet_image_local_storage.dart';
import '../../data/models/animal_model.dart';
import '../cubit/pets_cubit.dart';
import '../widgets/app_dropdown_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/month_year_picker.dart';
import '../widgets/pet_image_picker.dart';

// =============================================================
// حالة التطعيمة
// =============================================================
enum VaccineStatus {
  notYet, // لم يتم التطعيم بعد -> التاريخ = null
  withDate, // تم التطعيم (شهر + سنة)
}

class VaccineValue {
  final VaccineStatus status;
  final DateTime? date;

  const VaccineValue({
    this.status = VaccineStatus.notYet,
    this.date,
  });

  DateTime? toDate() {
    switch (status) {
      case VaccineStatus.notYet:
        return null;
      case VaccineStatus.withDate:
        return date;
    }
  }
}

class AddPetScreen extends StatefulWidget {
  final PetCategory category;

  const AddPetScreen({
    super.key,
    required this.category,
  });

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();

  AnimalGender _selectedGender = AnimalGender.male;

  // العمر: أي حقل ممكن يفضل فاضي (يتحفظ 0)
  int? _ageYears;
  int? _ageMonths;
  int? _ageDays;

  // الوزن: أي حقل ممكن يفضل فاضي (يتحفظ 0)
  int? _weightKg;
  int? _weightGrams;

  // التطعيمات
  VaccineValue _rabies = const VaccineValue();
  VaccineValue _core = const VaccineValue();

  // تواريخ تطعيمات الماعز والخروف مباشرة (شهر + سنة)
  DateTime? _smallpoxDate;
  DateTime? _fmdDate;
  DateTime? _mycoDate;

  // صورة الحيوان (اختيارية) - بتتحفظ في Hive بعد ما نجيب الـ id
  Uint8List? _petImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  String get _categoryTitle {
    switch (widget.category) {
      case PetCategory.cat:
        return 'قط';
      case PetCategory.dog:
        return 'كلب';
      case PetCategory.goat:
        return 'ماعز';
      case PetCategory.sheep:
        return 'خروف';
    }
  }

  /// أقصى وزن بالكيلو حسب نوع الحيوان
  int get _maxWeightKg {
    switch (widget.category) {
      case PetCategory.cat:
        return 15;
      case PetCategory.dog:
        return 100;
      case PetCategory.goat:
      case PetCategory.sheep:
        return 150;
    }
  }

  bool get _isCat => widget.category == PetCategory.cat;
  bool get _isDog => widget.category == PetCategory.dog;
  bool get _isCatOrDog => _isCat || _isDog;

  bool get _isGoat => widget.category == PetCategory.goat;
  bool get _isSheep => widget.category == PetCategory.sheep;
  bool get _isGoatOrSheep => _isGoat || _isSheep;

  /// عنوان التطعيمة الأساسية حسب النوع (قطة أم كلب)
  String get _coreVaccineTitle {
    if (_isDog) {
      return 'آخر تطعيمة أساسية (رباعي / خماسي / ثماني)';
    } else {
      return 'آخر تطعيمة أساسية (ثلاثي / رباعي)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PetsCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                _isGoatOrSheep ? 'بيانات الحيوان(فردي/قطيع)' : 'بيانات الحيوان',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            body: SafeArea(
              child: BlocListener<PetsCubit, PetsState>(
                listener: (context, state) {
                  if (state is PetsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------- إذا كان خروف أو ماعز ----------
                        if (_isGoatOrSheep) ...[
                          const SizedBox(height: 12),
                          // أيقونة الماعز/الخروف في دائرة
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5EE),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF168052),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.pets,
                                size: 45,
                                color: Color(0xFF168052),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // آخر تطعيمة الجدري
                          MonthYearPicker(
                            title: 'أخر تطعيمة الجدري',
                            value: _smallpoxDate,
                            onChanged: (date) {
                              setState(() {
                                _smallpoxDate = date;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // آخر تطعيمة حمة القلاعية
                          MonthYearPicker(
                            title: 'أخر تطعيمة حمة القلاعية',
                            value: _fmdDate,
                            onChanged: (date) {
                              setState(() {
                                _fmdDate = date;
                              });
                            },
                          ),

                          // إذا كان ماعز يضاف مايكروبلازمة (أبو الرمح)
                          if (_isGoat) ...[
                            const SizedBox(height: 20),
                            MonthYearPicker(
                              title: 'أخر تطعيمة مايكروبلازمة (أبو الرمح)',
                              value: _mycoDate,
                              onChanged: (date) {
                                setState(() {
                                  _mycoDate = date;
                                });
                              },
                            ),
                          ],
                        ]
                        // ---------- إذا كان قطة أو كلب ----------
                        else ...[
                          // ---------- صورة الحيوان ----------
                          PetImagePicker(
                            onChanged: (bytes) => _petImageBytes = bytes,
                          ),

                          const SizedBox(height: 24),

                          // ---------- نوع الحيوان (ثابت) ----------
                          _buildFieldLabel('نوع الحيوان'),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF168052),
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              _categoryTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF168052),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ---------- الاسم ----------
                          _buildFieldLabel('اسم الحيوان'),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _nameController,
                            hintText: 'مثال: كيتي',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'من فضلك أدخل اسم الحيوان';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // ---------- الجنس ----------
                          _buildFieldLabel('الجنس'),
                          const SizedBox(height: 6),
                          GenderSelector(
                            selectedGender: _selectedGender,
                            onChanged: (gender) {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          // ---------- العمر (اختياري لكل حقل) ----------
                          _buildFieldLabel('العمر'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: AppDropdownField<int>(
                                  hint: 'السنين',
                                  value: _ageYears,
                                  items: List.generate(51, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text('$index سنة'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      _ageYears = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppDropdownField<int>(
                                  hint: 'الشهور',
                                  value: _ageMonths,
                                  items: List.generate(12, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text('$index شهر'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      _ageMonths = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppDropdownField<int>(
                                  hint: 'الأيام',
                                  value: _ageDays,
                                  items: List.generate(30, (index) {
                                    final day = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: day,
                                      child: Text('$day يوم'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      _ageDays = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ---------- الفصيلة ----------
                          _buildFieldLabel('الفصيلة'),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _breedController,
                            hintText: 'من فضلك أدخل فصيلة الحيوان',
                            prefixIcon: const Icon(
                              Icons.pets,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'من فضلك أدخل الفصيلة';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // ---------- الوزن ----------
                          _buildFieldLabel('الوزن'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: AppDropdownField<int>(
                                  hint: 'كجم',
                                  value: _weightKg,
                                  items: List.generate(_maxWeightKg + 1, (kg) {
                                    return DropdownMenuItem<int>(
                                      value: kg,
                                      child: Text('$kg كجم'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      _weightKg = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppDropdownField<int>(
                                  hint: 'جرام',
                                  value: _weightGrams,
                                  items: List.generate(20, (i) {
                                    final grams = i * 50;
                                    return DropdownMenuItem<int>(
                                      value: grams,
                                      child: Text('$grams جرام'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      _weightGrams = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          _buildVaccineField(
                            title: 'آخر تطعيمة سعار',
                            value: _rabies,
                            onChanged: (v) => setState(() => _rabies = v),
                          ),
                          const SizedBox(height: 18),
                          _buildVaccineField(
                            title: _coreVaccineTitle,
                            value: _core,
                            onChanged: (v) => setState(() => _core = v),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // ---------- زر الحفظ ----------
                        BlocBuilder<PetsCubit, PetsState>(
                          builder: (context, state) {
                            final isLoading = state is PetsLoading;

                            return ElevatedButton(
                              onPressed:
                              isLoading ? null : () => _savePet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF168052),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                const Color(0xFF9BBBAA),
                                elevation: 0,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'حفظ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // حفظ الحيوان
  // =========================================================
  Future<void> _savePet(BuildContext blocContext) async {
    // Validation للقطط والكلاب
    if (_isCatOrDog) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_ageYears == null && _ageMonths == null && _ageDays == null) {
        _showMessage(
          'من فضلك اختر عمر الحيوان (سنين أو شهور أو أيام)',
          isError: true,
        );
        return;
      }

      if (_weightKg == null && _weightGrams == null) {
        _showMessage(
          'من فضلك اختر وزن الحيوان',
          isError: true,
        );
        return;
      }
    }

    // Validation لحيوانات المزرعة (الخروف والماعز)
    if (_isGoatOrSheep) {
      if (_smallpoxDate == null) {
        _showMessage('من فضلك اختر تاريخ أخر تطعيمة للجدري', isError: true);
        return;
      }
      if (_fmdDate == null) {
        _showMessage('من فضلك اختر تاريخ أخر تطعيمة لحمة القلاعية',
            isError: true);
        return;
      }
      if (_isGoat && _mycoDate == null) {
        _showMessage('من فضلك اختر تاريخ أخر تطعيمة لمايكروبلازمة (أبو الرمح)',
            isError: true);
        return;
      }
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('يجب تسجيل الدخول أولًا', isError: true);
      return;
    }

    final pet = AnimalModel(
      name: _isGoatOrSheep ? _categoryTitle : _nameController.text.trim(),
      gender: _selectedGender,
      category: widget.category,

      ageYears: _ageYears ?? 0,
      ageMonths: _ageMonths ?? 0,
      ageDays: _ageDays ?? 0,

      breed: _isGoatOrSheep ? _categoryTitle : _breedController.text.trim(),
      weightKg: _weightKg ?? 0,
      weightGrams: _weightGrams ?? 0,

      lastRabiesDate: _isCatOrDog ? _rabies.toDate() : null,
      lastCoreDate: _isCatOrDog ? _core.toDate() : null,
      lastSmallpoxDate: _isGoatOrSheep ? _smallpoxDate : null,
      lastFmdDate: _isGoatOrSheep ? _fmdDate : null,
      lastMycoDate: _isGoat ? _mycoDate : null,
    );

    final cubit = blocContext.read<PetsCubit>();
    final petId = await cubit.addPet(pet, user.uid);

    if (!mounted) {
      return;
    }

    if (petId == null) {
      return;
    }

    // ---------------------------------------------------------
    // حفظ الصورة (اختيارية) في Hive بمفتاح = Firestore document id
    // فشل حفظ الصورة لا يمنع حفظ بيانات الحيوان
    // ---------------------------------------------------------
    if (_petImageBytes != null) {
      try {
        await PetImageLocalStorage.instance.saveImage(
          petId,
          _petImageBytes!,
        );
      } catch (e) {
        debugPrint('Failed to save pet image: $e');
      }

      if (!mounted) {
        return;
      }
    }

    _showMessage('تم حفظ بيانات الحيوان بنجاح');

    // الانتقال مباشرة للـ Home وإزالة كل الشاشات السابقة من الـ Stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF168052),
      ),
    );
  }

  // =========================================================
  // Widgets مساعدة
  // =========================================================

  Widget _buildVaccineField({
    required String title,
    required VaccineValue value,
    required ValueChanged<VaccineValue> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFieldLabel(title),
        const SizedBox(height: 6),
        AppDropdownField<VaccineStatus>(
          hint: 'اختر حالة التطعيم',
          value: value.status,
          items: const [
            DropdownMenuItem<VaccineStatus>(
              value: VaccineStatus.notYet,
              child: Text('لم يتم التطعيم بعد'),
            ),
            DropdownMenuItem<VaccineStatus>(
              value: VaccineStatus.withDate,
              child: Text('تم التطعيم (اختر الشهر والسنة)'),
            ),
          ],
          onChanged: (status) {
            if (status == null) return;

            if (status == VaccineStatus.withDate) {
              final now = DateTime.now();
              onChanged(
                VaccineValue(
                  status: status,
                  date: value.date ?? DateTime(now.year, now.month),
                ),
              );
            } else {
              onChanged(VaccineValue(status: status, date: value.date));
            }
          },
        ),
        if (value.status == VaccineStatus.withDate) ...[
          const SizedBox(height: 12),
          MonthYearPicker(
            title: 'شهر وسنة آخر تطعيمة',
            value: value.date,
            onChanged: (date) {
              onChanged(VaccineValue(status: value.status, date: date));
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6E4DC),
          width: 1.2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA0AEC0),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}