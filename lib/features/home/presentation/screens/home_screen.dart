import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../pets/data/models/animal_model.dart';
import '../../../pets/presentation/screens/pet_category_screen.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/presentation/cubit/store_cubit.dart';
import '../../../vaccinations/data/calculators/vaccination/vaccination_calculator.dart';
import '../../../vaccinations/presentation/views/pet_details_view.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_page_content.dart';

class HomeScreen extends StatelessWidget {
  final bool scrollToPetsOnOpen;

  const HomeScreen({super.key, this.scrollToPetsOnOpen = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<StoreCubit>()..watchStore()),
        BlocProvider(create: (_) => sl<HomeCubit>()..loadPets()),
      ],
      child: _HomeView(scrollToPetsOnOpen: scrollToPetsOnOpen),
    );
  }
}

class _HomeView extends StatefulWidget {
  final bool scrollToPetsOnOpen;

  const _HomeView({required this.scrollToPetsOnOpen});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _petsSectionKey = GlobalKey();
  var _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.scrollToPetsOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToPets();
      });
    }
  }

  Future<void> _loadPets() => context.read<HomeCubit>().loadPets();

  Future<void> _openAddPet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PetCategoryScreen()),
    );
    if (mounted) await _loadPets();
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 0) {
      setState(() => _selectedBottomNavIndex = 0);
      return;
    }

    if (index == 2) {
      setState(() => _selectedBottomNavIndex = index);
      _scrollToPets();
      return;
    }

    setState(() => _selectedBottomNavIndex = index);
    final route = switch (index) {
      1 => RouteNames.store,
      3 => RouteNames.orders,
      4 => RouteNames.profile,
      _ => null,
    };
    if (route != null) await Navigator.pushNamed(context, route);
    if (mounted) setState(() => _selectedBottomNavIndex = 0);
  }

  Future<void> _openVaccinations([AnimalModel? pet]) async {
    final state = context.read<HomeCubit>().state;
    final selectedPet = pet ?? (state.pets.isEmpty ? null : state.pets.first);
    if (selectedPet == null) {
      _showMessage('أضف حيوانًا أليفًا أولًا لعرض تفاصيله.');
      return;
    }

    final imageBytes = state.petImages[selectedPet.id];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetDetailsView(
          animal: selectedPet,
          scheduleBuilder: VaccinationCalculator.calculateForAnimal,
          image: imageBytes == null ? null : MemoryImage(imageBytes),
        ),
      ),
    );
  }

  void _openStore({String? categoryId}) {
    Navigator.pushNamed(context, RouteNames.store, arguments: categoryId);
  }

  void _openProduct(ProductModel product) {
    Navigator.pushNamed(
      context,
      RouteNames.productDetails,
      arguments: product.id,
    );
  }

  Future<void> _addProductToCart(ProductModel product) async {
    final added = await context.read<StoreCubit>().addToCart(product);
    if (!mounted) return;
    _showMessage(
      added
          ? 'تمت إضافة ${product.name} إلى السلة.'
          : 'سجّل الدخول أولًا لإضافة المنتج للسلة.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToPets() {
    final petsContext = _petsSectionKey.currentContext;
    if (petsContext == null) return;
    Scrollable.ensureVisible(
      petsContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) => _showMessage(state.errorMessage!),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final displayName = state.userName.isEmpty
              ? 'مرحبًا بك'
              : state.userName;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              drawer: HomeDrawer(
                userName: displayName,
                email: state.userEmail,
                onCategorySelected: (categoryId) =>
                    _openStore(categoryId: categoryId),
                onProfileTap: () =>
                    Navigator.pushNamed(context, RouteNames.profile),
                onSettingsTap: () =>
                    _showMessage('صفحة الإعدادات هتتضاف لاحقًا.'),
                onFavoritesTap: () =>
                    _showMessage('صفحة المفضلة هتتضاف مع تنفيذ ميزتها.'),
              ),
              body: SafeArea(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadPets,
                  child: HomePageContent(
                    state: state,
                    petsSectionKey: _petsSectionKey,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onNotificationsTap: () =>
                        Navigator.pushNamed(context, RouteNames.notifications),
                    onSearchTap: () =>
                        Navigator.pushNamed(context, RouteNames.search),
                    onStoreTap: _openStore,
                    onVaccinationsTap: () => _openVaccinations(),
                    onServicesTap: () =>
                        _showMessage('الخدمات البيطرية ستتوفر قريبًا.'),
                    onOrdersTap: () =>
                        Navigator.pushNamed(context, RouteNames.orders),
                    onAddPetTap: _openAddPet,
                    onViewAllPetsTap: _scrollToPets,
                    onPetTap: _openVaccinations,
                    onProductTap: _openProduct,
                    onAddToCart: _addProductToCart,
                  ),
                ),
              ),
              bottomNavigationBar: HomeBottomNav(
                currentIndex: _selectedBottomNavIndex,
                onTap: _onBottomNavTap,
              ),
            ),
          );
        },
      ),
    );
  }
}
