import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/routing/route_names.dart';

import '../../../pets/data/datasources/pets_remote_data_source.dart';
import '../../../pets/data/local/pet_image_local_storage.dart';
import '../../../pets/data/models/animal_model.dart';
import '../../../pets/data/repositories/pets_repository.dart';
import '../../../pets/presentation/screens/pet_category_screen.dart';
import '../home_colors.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/my_pets_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_vaccine_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<AnimalModel> _pets = [];

  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  // ===============================================================
  // PETS REPOSITORY
  // ===============================================================

  PetsRepository _petsRepository() {
    final getIt = GetIt.instance;

    if (getIt.isRegistered<PetsRepository>()) {
      return getIt<PetsRepository>();
    }

    // Fallback فقط لو الـ Repository مش متسجل في GetIt.
    return PetsRepository(
      PetsRemoteDataSource(
        FirebaseFirestore.instance,
      ),
    );
  }

  // ===============================================================
  // LOAD PETS
  // ===============================================================

  Future<void> _loadPets() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
      }
      return;
    }

    try {
      setState(() {
        _isLoadingPets = true;
      });

      // تهيئة Hive لتخزين صور الحيوانات محليًا.
      await PetImageLocalStorage.instance.init();

      final pets = await _petsRepository().getPets(user.uid);

      if (!mounted) return;

      setState(() {
        _pets = pets;
        _isLoadingPets = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Failed to load pets: $e');

      setState(() {
        _isLoadingPets = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تعذر تحميل الحيوانات، حاولي مرة أخرى',
            textDirection: TextDirection.rtl,
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ===============================================================
  // ADD PET
  // ===============================================================

  Future<void> _openAddPet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PetCategoryScreen(),
      ),
    );

    if (mounted) {
      await _loadPets();
    }
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // TODO:
    // توجيه المستخدم إلى LoginScreen
    // بعد ربط الـ AuthGate / Navigation.
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final userName = user?.displayName?.trim() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HomeColors.background,

        // =========================================================
        // BODY
        // =========================================================

        body: SafeArea(
          child: RefreshIndicator(
            color: HomeColors.primary,
            backgroundColor: Colors.white,
            strokeWidth: 2.4,
            onRefresh: _loadPets,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 12.h,
                    bottom: 20.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // =================================================
                        // HEADER
                        // =================================================

                        _buildHeader(
                          user: user,
                          userName: userName,
                        ),

                        SizedBox(height: 18.h),

                        // =================================================
                        // SEARCH
                        // =================================================

                        const HomeSearchBar(),

                        SizedBox(height: 18.h),

                        // =================================================
                        // PROMO BANNER
                        // =================================================

                        PromoBanner(
                          onTap: () {
                            // TODO:
                            // فتح المتجر / صفحة العرض
                          },
                        ),

                        SizedBox(height: 20.h),

                        // =================================================
                        // QUICK ACTIONS TITLE
                        // =================================================

                        const _SectionTitle(
                          title: 'الوصول السريع',
                        ),

                        SizedBox(height: 10.h),

                        // =================================================
                        // QUICK ACTIONS
                        // =================================================

                        QuickActionsGrid(
                          onVaccinesTap: () {
                            // TODO:
                            // شاشة التطعيمات
                          },
                          onMyPetsTap: () {
                            // TODO:
                            // شاشة حيواناتي
                          },
                          onStoreTap: () {
                            // TODO:
                            // شاشة المتجر
                          },
                          onServicesTap: () {
                            // TODO:
                            // شاشة الخدمات
                          },
                        ),

                        SizedBox(height: 22.h),

                        // =================================================
                        // UPCOMING VACCINE
                        // =================================================

                        const _SectionTitle(
                          title: 'التطعيم القادم',
                        ),

                        SizedBox(height: 10.h),

                        UpcomingVaccineCard(
                          vaccineName: 'التطعيم الرباعي',
                          petName: 'تاتا',
                          date: '11/11/2026',
                          onDetailsTap: () {
                            // TODO:
                            // تفاصيل التطعيمة
                          },
                        ),

                        SizedBox(height: 24.h),

                        // =================================================
                        // MY PETS HEADER
                        // =================================================

                        _SectionHeader(
                          title: 'حيواناتي',
                          iconText: '🐾',
                          actionText: 'عرض الكل',
                          onActionTap: () {
                            // TODO:
                            // شاشة كل الحيوانات
                          },
                        ),

                        SizedBox(height: 12.h),

                        // =================================================
                        // MY PETS
                        // =================================================

                        _buildPetsSection(),

                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ===========================================================
        // BOTTOM NAVIGATION
        // ===========================================================

        bottomNavigationBar: HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader({
    required User? user,
    required String userName,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 4.h,
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------
          // USER / HOME HEADER
          // ---------------------------------------------------------

          Expanded(
            child: HomeHeader(
              userName: userName.isEmpty
                  ? 'مرحبا عزيزي'
                  : userName,
              photoUrl: user?.photoURL,
              notificationsCount: 3,
              onNotificationsTap: () {
                // TODO:
                // شاشة الإشعارات
              },
            ),
          ),

          SizedBox(width: 8.w),

          // ---------------------------------------------------------
          // LOGOUT BUTTON
          // ---------------------------------------------------------

          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 20.sp,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PETS SECTION
  // ===============================================================

  Widget _buildPetsSection() {
    // -------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------

    if (_isLoadingPets) {
      return SizedBox(
        height: 145.h,
        child: Center(
          child: SizedBox(
            width: 28.w,
            height: 28.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: HomeColors.primary,
            ),
          ),
        ),
      );
    }

    // -------------------------------------------------------------
    // PETS LIST
    // -------------------------------------------------------------

    return MyPetsSection(
      showHeader: false,
      pets: _pets,
      onAddTap: _openAddPet,
      onPetTap: (pet) {
        // TODO:
        // شاشة تفاصيل الحيوان باستخدام pet.id
      },

      // صورة الحيوان من Hive.
      // المفتاح = pet.id
      imageBuilder: (pet) {
        final bytes =
        PetImageLocalStorage.instance.getImage(
          pet.id,
        );

        if (bytes == null) {
          return null;
        }

        return MemoryImage(bytes);
      },
    );
  }
}

// ===============================================================
// SECTION TITLE
// ===============================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: HomeColors.textPrimary,
          height: 1.2,
        ),
      ),
    );
  }
}

// ===============================================================
// SECTION HEADER
// ===============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? iconText;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.iconText,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // -----------------------------------------------------------
        // TITLE
        // -----------------------------------------------------------

        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: HomeColors.textPrimary,
                height: 1.2,
              ),
            ),

            if (iconText != null) ...[
              SizedBox(width: 6.w),

              Text(
                iconText!,
                style: TextStyle(
                  fontSize: 17.sp,
                ),
              ),
            ],
          ],
        ),

        // -----------------------------------------------------------
        // SEE ALL
        // -----------------------------------------------------------

        if (actionText != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 5.h,
                ),
                child: Text(
                  actionText!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeColors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
