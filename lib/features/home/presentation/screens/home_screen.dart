import 'dart:ui' show PointerDeviceKind;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../pets/data/local/pet_image_local_storage.dart';
import '../../../pets/data/models/animal_model.dart';
import '../../../pets/data/repositories/pets_repository.dart';
import '../../../pets/presentation/screens/pet_category_screen.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/presentation/cubit/store_cubit.dart';
import '../../../store/presentation/cubit/store_state.dart';
import '../../../vaccinations/presentation/cubit/vaccinations_cubit.dart';
import '../../../vaccinations/presentation/views/vaccinations_view.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/my_pets_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<StoreCubit>()..watchStore(),
        child: const _HomeView(),
      );
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  List<AnimalModel> _pets = [];
  bool _isLoadingPets = true;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingPets = false);
      return;
    }
    try {
      await PetImageLocalStorage.instance.init();
      final pets = await sl<PetsRepository>().getPets(user.uid);
      if (mounted) setState(() {
        _pets = pets;
        _isLoadingPets = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingPets = false);
    }
  }

  Future<void> _openAddPet() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const PetCategoryScreen()));
    if (mounted) await _loadPets();
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 0) {
      setState(() => _selectedBottomNavIndex = 0);
      return;
    }
    setState(() => _selectedBottomNavIndex = index);
    switch (index) {
      case 1:
        await Navigator.pushNamed(context, RouteNames.store);
      case 2:
        await Navigator.pushNamed(context, RouteNames.cart);
      case 3:
        await Navigator.pushNamed(context, RouteNames.orders);
      case 4:
        await _openVaccinations();
    }
    if (mounted) setState(() => _selectedBottomNavIndex = 0);
  }

  Future<void> _openVaccinations([AnimalModel? pet]) async {
    final selectedPet = pet ?? (_pets.isEmpty ? null : _pets.first);
    if (selectedPet == null) {
      _showMessage('أضف حيوانًا أليفًا أولًا لعرض تطعيماته.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<VaccinationsCubit>(
          create: (_) => sl<VaccinationsCubit>(),
          child: VaccinationsView(petId: selectedPet.id),
        ),
      ),
    );
  }

  void _openStore({String? categoryId}) {
    Navigator.pushNamed(context, RouteNames.store, arguments: categoryId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToPets() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),
        drawer: HomeDrawer(
          userName: name == null || name.isEmpty ? 'مرحبًا بك' : name,
          email: user?.email,
          onCategorySelected: (categoryId) => _openStore(categoryId: categoryId),
          onProfileTap: () => _showMessage('صفحة البروفايل هتتضاف لاحقًا.'),
          onSettingsTap: () => _showMessage('صفحة الإعدادات هتتضاف لاحقًا.'),
          onFavoritesTap: () => Navigator.pushNamed(context, RouteNames.favorites),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadPets,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  sliver: SliverList.list(
                    children: [
                      _header(name),
                      SizedBox(height: 18.h),
                      HomeSearchBar(onTap: () => Navigator.pushNamed(context, RouteNames.search)),
                      SizedBox(height: 18.h),
                      _promotionBanner(),
                      SizedBox(height: 24.h),
                      _sectionHeader('خدماتنا السريعة'),
                      SizedBox(height: 12.h),
                      _quickServices(),
                      SizedBox(height: 24.h),
                      _sectionHeader('حيواناتك الأليفة', action: 'عرض الكل', onAction: _scrollToPets),
                      SizedBox(height: 12.h),
                      _petsSection(),
                      SizedBox(height: 24.h),
                      _sectionHeader('منتجات مميزة', action: 'عرض المتجر', onAction: _openStore),
                      SizedBox(height: 12.h),
                      _featuredProducts(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _selectedBottomNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _header(String? name) => Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'القائمة',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: FirebaseAuth.instance.currentUser?.photoURL == null
                ? null
                : NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
            child: FirebaseAuth.instance.currentUser?.photoURL == null
                ? const Icon(Icons.person_outline, color: AppColors.primaryDark)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أهلًا بك،', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                Text(
                  name == null || name.isEmpty ? 'في Vet Care' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.mainText),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () => _showMessage('الإشعارات غير متاحة على هذا الإصدار حاليًا.'),
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryDark),
          ),
        ],
      );

  Widget _promotionBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF267D68), Color(0xFF1E6554)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('كل احتياجات أليفك في مكان واحد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            const Text('منتجات مختارة لرعاية أفضل كل يوم', style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _openStore,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white),
              child: const Text('تسوق الآن'),
            ),
          ],
        ),
      );

  Widget _quickServices() => Row(
        children: [
          _service('المتجر', Icons.medication_outlined, const Color(0xFFEF4444), const Color(0xFFFFECEF), _openStore),
          _service('التطعيمات', Icons.verified_user_outlined, const Color(0xFF2563EB), const Color(0xFFEFF6FF), _openVaccinations),
          _service('الخدمات', Icons.support_agent_outlined, const Color(0xFFF59E0B), const Color(0xFFFEF3C7), () => _showMessage('الخدمات البيطرية ستتوفر قريبًا.')),
          _service('طلباتي', Icons.local_shipping_outlined, AppColors.primaryDark, AppColors.primaryLight, () => Navigator.pushNamed(context, RouteNames.orders)),
        ],
      );

  Widget _service(String title, IconData icon, Color iconColor, Color background, VoidCallback onTap) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
                child: Column(
                  children: [
                    CircleAvatar(radius: 22, backgroundColor: background, child: Icon(icon, color: iconColor, size: 21)),
                    const SizedBox(height: 7),
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _petsSection() {
    if (_isLoadingPets) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus},
      ),
      child: MyPetsSection(
        showHeader: false,
        pets: _pets,
        onAddTap: _openAddPet,
        onViewAllTap: _scrollToPets,
        onPetTap: _openVaccinations,
        imageBuilder: (pet) {
          final bytes = PetImageLocalStorage.instance.getImage(pet.id);
          return bytes == null ? null : MemoryImage(bytes);
        },
      ),
    );
  }

  Widget _featuredProducts() => BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          if (state.isLoading && state.products.isEmpty) {
            return const SizedBox(height: 170, child: Center(child: CircularProgressIndicator()));
          }
          if (state.products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('المنتجات المميزة ستظهر هنا عند توفرها.')),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              final products = state.products.take(4).toList();
              return GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) => _featuredProductCard(products[index]),
              );
            },
          );
        },
      );

  Widget _featuredProductCard(ProductModel product) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, RouteNames.productDetails, arguments: product.id),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppImage(imageUrl: product.imageUrl, borderRadius: BorderRadius.circular(12))),
                const SizedBox(height: 8),
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('${product.price} ج.م', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark))),
                    IconButton.filled(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _addProductToCart(context, product),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 17),
                      tooltip: 'أضف للسلة',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _addProductToCart(BuildContext context, ProductModel product) async {
    final added = await context.read<StoreCubit>().addToCart(product);
    if (!mounted) return;
    _showMessage(added ? 'تمت إضافة ${product.name} إلى السلة.' : 'سجّل الدخول أولًا لإضافة المنتج للسلة.');
  }

  Widget _sectionHeader(String title, {String? action, VoidCallback? onAction}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.mainText)),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action, style: const TextStyle(color: AppColors.primaryDark, fontSize: 12))),
        ],
      );
}
