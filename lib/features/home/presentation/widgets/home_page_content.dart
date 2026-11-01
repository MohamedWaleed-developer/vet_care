import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../pets/data/models/animal_model.dart';
import '../../../store/data/models/product_model.dart';
import '../cubit/home_state.dart';
import 'featured_products_section.dart';
import 'home_header_section.dart';
import 'home_pets_section.dart';
import 'home_promotion_banner.dart';
import 'home_quick_services.dart';
import 'home_search_bar.dart';
import 'home_section_header.dart';

class HomePageContent extends StatelessWidget {
  final HomeState state;
  final GlobalKey petsSectionKey;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSearchTap;
  final VoidCallback onStoreTap;
  final VoidCallback onVaccinationsTap;
  final VoidCallback onServicesTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onAddPetTap;
  final VoidCallback onViewAllPetsTap;
  final ValueChanged<AnimalModel> onPetTap;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;

  const HomePageContent({
    super.key,
    required this.state,
    required this.petsSectionKey,
    required this.onMenuTap,
    required this.onNotificationsTap,
    required this.onSearchTap,
    required this.onStoreTap,
    required this.onVaccinationsTap,
    required this.onServicesTap,
    required this.onOrdersTap,
    required this.onAddPetTap,
    required this.onViewAllPetsTap,
    required this.onPetTap,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          sliver: SliverList.list(
            children: [
              HomeHeaderSection(
                userName: state.userName,
                photoUrl: state.photoUrl,
                onMenuTap: onMenuTap,
                onNotificationsTap: onNotificationsTap,
              ),
              SizedBox(height: 18.h),
              HomeSearchBar(onTap: onSearchTap),
              SizedBox(height: 18.h),
              HomePromotionBanner(onStoreTap: onStoreTap),
              SizedBox(height: 24.h),
              const HomeSectionHeader(title: 'خدماتنا السريعة'),
              SizedBox(height: 12.h),
              HomeQuickServices(
                onStoreTap: onStoreTap,
                onVaccinationsTap: onVaccinationsTap,
                onServicesTap: onServicesTap,
                onOrdersTap: onOrdersTap,
              ),
              SizedBox(height: 24.h),
              KeyedSubtree(
                key: petsSectionKey,
                child: Column(
                  children: [
                    HomeSectionHeader(
                      title: 'حيواناتك الأليفة',
                      action: 'عرض الكل',
                      onAction: onViewAllPetsTap,
                    ),
                    SizedBox(height: 12.h),
                    HomePetsSection(
                      isLoading: state.isLoadingPets,
                      pets: state.pets,
                      petImages: state.petImages,
                      onAddTap: onAddPetTap,
                      onViewAllTap: onViewAllPetsTap,
                      onPetTap: onPetTap,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              HomeSectionHeader(
                title: 'منتجات مميزة',
                action: 'عرض المتجر',
                onAction: onStoreTap,
              ),
              SizedBox(height: 12.h),
              FeaturedProductsSection(
                onProductTap: onProductTap,
                onAddToCart: onAddToCart,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
