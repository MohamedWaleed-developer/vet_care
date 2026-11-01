import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../store/presentation/cubit/store_cubit.dart';
import '../../../store/presentation/cubit/store_state.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;
  final String? email;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onFavoritesTap;

  const HomeDrawer({
    super.key,
    required this.userName,
    required this.email,
    required this.onCategorySelected,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: const Color(0xFFF8F9FA),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF267D68), Color(0xFF1E6554)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline, color: AppColors.primaryDark, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          if (email != null && email!.isNotEmpty)
                            Text(email!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD7E9E3), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _item(context, Icons.person_outline, 'البروفايل', () => _runAfterClose(context, onProfileTap)),
                    _item(context, Icons.favorite_border, 'المفضلة', () => _runAfterClose(context, onFavoritesTap)),
                    _item(context, Icons.settings_outlined, 'الإعدادات', () => _runAfterClose(context, onSettingsTap)),
                    const Divider(indent: 16, endIndent: 16),
                    _item(context, Icons.shopping_bag_outlined, 'السلة', () => _openRoute(context, RouteNames.cart)),
                    _item(context, Icons.receipt_long_outlined, 'طلباتي', () => _openRoute(context, RouteNames.orders)),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
                      child: Text('أقسام المتجر', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    _item(context, Icons.storefront_outlined, 'كل المنتجات', () => _selectCategory(context, null)),
                    BlocBuilder<StoreCubit, StoreState>(
                      builder: (context, state) {
                        if (state.categories.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text('لا توجد أقسام متاحة حاليًا.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                          );
                        }
                        return Column(
                          children: state.categories
                              .map((category) => _item(
                                    context,
                                    Icons.category_outlined,
                                    category.name,
                                    () => _selectCategory(context, category.id),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Vet Care', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ),
            ],
          ),
        ),
      );

  Widget _item(BuildContext context, IconData icon, String title, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        onTap: onTap,
        dense: true,
      );

  void _openRoute(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _selectCategory(BuildContext context, String? categoryId) {
    Navigator.pop(context);
    onCategorySelected(categoryId);
  }

  void _runAfterClose(BuildContext context, VoidCallback callback) {
    Navigator.pop(context);
    callback();
  }
}
