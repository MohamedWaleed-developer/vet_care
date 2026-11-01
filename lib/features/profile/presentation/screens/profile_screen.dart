import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ProfileCubit>()..loadProfile(),
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.initial) {
              return const AppLoader();
            }
            if (state.status == ProfileStatus.failure &&
                state.profile == null) {
              return _ProfileLoadError(
                message: state.errorMessage ?? 'تعذر تحميل الملف الشخصي.',
              );
            }

            final profile = state.profile;
            if (profile == null) return const AppLoader();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _ProfileHeader(
                          name: profile.name,
                          phoneNumber: profile.phoneNumber,
                          photoBytes: profile.photoBytes,
                          onEdit: () => _editProfile(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  FutureBuilder<bool>(
                                    future: sl<AdminRepository>().isAdmin(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data != true) {
                                        return const SizedBox.shrink();
                                      }
                                      return ProfileMenuItem(
                                        title: 'إدارة المنتجات',
                                        subtitle: 'إضافة وتعديل منتجات المتجر',
                                        icon:
                                            Icons.admin_panel_settings_outlined,
                                        onTap: () => Navigator.of(
                                          context,
                                        ).pushNamed(RouteNames.admin),
                                      );
                                    },
                                  ),
                                  ProfileMenuItem(
                                    title: 'عناوين التوصيل',
                                    subtitle: 'إدارة عناوين الشحن الخاصة بك',
                                    icon: Icons.location_on_outlined,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'إدارة عناوين التوصيل',
                                    ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'طرق الدفع',
                                    subtitle: 'إدارة طرق الدفع الخاصة بك',
                                    icon: Icons.credit_card_outlined,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'طرق الدفع المحفوظة',
                                    ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'حيواناتي الأليفة',
                                    subtitle: 'عرض حيواناتك وإدارتها',
                                    icon: Icons.pets_outlined,
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                          RouteNames.home,
                                          arguments: 'pets',
                                        ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'سجل التحصينات اللقاحية',
                                    subtitle:
                                        'مواعيد اللقاحات القادمة والسابقة',
                                    icon: Icons.calendar_month_outlined,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'سجل التحصينات',
                                    ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'لغة التطبيق',
                                    subtitle: 'العربية',
                                    icon: Icons.language_outlined,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'تغيير لغة التطبيق',
                                    ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'مركز المساعدة والدعم',
                                    subtitle: 'الأسئلة الشائعة والتواصل معنا',
                                    icon: Icons.headset_mic_outlined,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'مركز المساعدة',
                                    ),
                                  ),
                                  ProfileMenuItem(
                                    title: 'تقييم التطبيق',
                                    subtitle: 'رأيك يساعدنا على التطوير',
                                    icon: Icons.star_outline_rounded,
                                    onTap: () => _showComingSoon(
                                      context,
                                      'تقييم التطبيق',
                                    ),
                                  ),
                                  const _AdminProductsMenuItem(),
                                  ProfileMenuItem(
                                    title: 'تسجيل الخروج',
                                    subtitle: 'الخروج الآمن من حسابك الحالي',
                                    icon: Icons.logout_rounded,
                                    isDestructive: true,
                                    showDivider: false,
                                    onTap: () => _confirmLogout(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                HomeBottomNav(
                  currentIndex: 4,
                  onTap: (index) => _navigateFromBottomNav(context, index),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Future<void> _editProfile(BuildContext context) async {
    final profile = context.read<ProfileCubit>().state.profile;
    if (profile == null) return;

    final emailVerificationSent =
        await Navigator.of(
          context,
        ).pushNamed<dynamic>(RouteNames.editProfile, arguments: profile) ==
        true;
    if (!context.mounted) return;
    await context.read<ProfileCubit>().loadProfile();
    if (context.mounted) context.read<AuthCubit>().checkCurrentUser();
    if (emailVerificationSent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أرسلنا رابط تحقق إلى البريد الإلكتروني الجديد.'),
        ),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
    if (shouldLogout != true || !context.mounted) return;

    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    if (context.read<AuthCubit>().state is AuthUnauthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (_) => false,
      );
    } else if (context.read<AuthCubit>().state case AuthError(:final message)) {
      _showMessage(context, message);
    }
  }

  void _navigateFromBottomNav(BuildContext context, int index) {
    final route = switch (index) {
      0 => RouteNames.home,
      1 => RouteNames.store,
      2 => RouteNames.home,
      3 => RouteNames.orders,
      _ => RouteNames.profile,
    };
    if (route == RouteNames.profile) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(route, arguments: index == 2 ? 'pets' : null);
  }

  void _showComingSoon(BuildContext context, String feature) {
    _showMessage(context, '$feature ستتوفر قريبًا.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AdminProductsMenuItem extends StatelessWidget {
  const _AdminProductsMenuItem();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: sl<AdminRepository>().isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return ProfileMenuItem(
          title: 'إدارة المنتجات',
          subtitle: 'إضافة المنتجات وتعديلها وإيقافها',
          icon: Icons.inventory_2_outlined,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.admin),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final Uint8List? photoBytes;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.name,
    required this.phoneNumber,
    required this.photoBytes,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E6554);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE6F3EF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              backgroundImage: photoBytes == null
                  ? null
                  : MemoryImage(photoBytes!),
              child: photoBytes == null
                  ? const Icon(
                      Icons.person_outline_rounded,
                      color: primaryColor,
                      size: 42,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isEmpty ? 'مستخدم Vet Care' : name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phoneNumber.isEmpty ? 'لم يُضف رقم جوال' : phoneNumber,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: primaryColor,
            ),
            label: const Text(
              'تعديل الملف الشخصي',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: primaryColor, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  final String message;

  const _ProfileLoadError({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}
