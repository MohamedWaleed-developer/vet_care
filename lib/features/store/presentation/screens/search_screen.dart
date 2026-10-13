import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_search_filter.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/product_card.dart';
import 'search_filter_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => sl<SearchCubit>()..watchStore(),
        child: const _SearchView(),
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _SearchField(
                controller: _searchController,
                onChanged: context.read<SearchCubit>().setQuery,
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.isLoading && state.allProducts.isEmpty) {
                    return const AppLoader();
                  }
                  if (state.errorMessage != null && state.allProducts.isEmpty) {
                    return AppError(
                      message: state.errorMessage!,
                      onRetry: () => context.read<SearchCubit>().watchStore(),
                    );
                  }
                  if (state.query.trim().isEmpty) {
                    return _SuggestionsView(
                      recentSearches: _recentSearches,
                      categories: state.categories,
                      onQuerySelected: _setQuery,
                      onClearRecent: () =>
                          setState(_recentSearches.clear),
                      onRemoveRecent: (query) => setState(
                        () => _recentSearches.remove(query),
                      ),
                    );
                  }
                  if (state.results.isEmpty) {
                    return _NoResultsView(
                      query: state.query,
                      products: state.recommendations,
                      onProductTap: _openProduct,
                      onAddToCart: _addToCart,
                    );
                  }
                  return _ResultsView(
                    state: state,
                    onFilterTap: () => _openFilters(state),
                    onProductTap: _openProduct,
                    onAddToCart: _addToCart,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    context.read<SearchCubit>().setQuery(query);
    _submitSearch(query);
  }

  void _submitSearch(String query) {
    final value = query.trim();
    if (value.isEmpty) return;
    setState(() {
      _recentSearches.remove(value);
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _openFilters(SearchState state) async {
    final filter = await Navigator.of(context).push<StoreSearchFilter>(
      MaterialPageRoute(
        builder: (_) => SearchFilterScreen(
          initialFilter: state.filter,
          maxPrice: state.maxPrice,
          brands: state.brands,
        ),
      ),
    );
    if (!mounted || filter == null) return;
    context.read<SearchCubit>().applyFilter(filter);
  }

  void _openProduct(ProductModel product) {
    Navigator.of(context).pushNamed(
      RouteNames.productDetails,
      arguments: product.id,
    );
  }

  Future<void> _addToCart(ProductModel product) async {
    final added = await context.read<SearchCubit>().addToCart(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added
              ? 'تمت إضافة ${product.name} إلى السلة'
              : 'تعذر الإضافة إلى السلة. تأكد من تسجيل الدخول وحاول مرة أخرى.'),
        ),
      );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: AppColors.mainText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج، علاج، أو طعام...',
          hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: IconButton(
            tooltip: 'مسح البحث',
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          ),
          suffixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  final List<String> recentSearches;
  final List<CategoryModel> categories;
  final ValueChanged<String> onQuerySelected;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onRemoveRecent;

  const _SuggestionsView({
    required this.recentSearches,
    required this.categories,
    required this.onQuerySelected,
    required this.onClearRecent,
    required this.onRemoveRecent,
  });

  static const _popularTerms = [
    'طعام هامستر',
    'حقن الديدان',
    'شامبو للقطط',
    'رمل فضلات القطط',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'عمليات البحث الأخيرة',
                  style: TextStyle(
                    color: AppColors.mainText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onClearRecent, child: const Text('مسح الكل')),
            ],
          ),
          ...recentSearches.map(
            (query) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: AppColors.secondaryText),
              title: Text(query),
              trailing: IconButton(
                tooltip: 'حذف البحث',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemoveRecent(query),
              ),
              onTap: () => onQuerySelected(query),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'عمليات بحث شائعة',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularTerms
              .map(
                (term) => ActionChip(
                  label: Text(term),
                  avatar: const Icon(Icons.trending_up, size: 16),
                  onPressed: () => onQuerySelected(term),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'تصفح الأقسام',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const AppEmpty(
            icon: Icons.category_outlined,
            message: 'ستظهر أقسام المتجر هنا عند توفرها',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryTile(
                category: category,
                index: index,
                onTap: () => onQuerySelected(category.name),
              );
            },
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.index,
    required this.onTap,
  });

  static const _icons = [
    Icons.face_retouching_natural_outlined,
    Icons.shield_outlined,
    Icons.medication_outlined,
    Icons.eco_outlined,
  ];
  static const _colors = [
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFFF59E0B),
    AppColors.primaryDark,
  ];
  static const _backgrounds = [
    Color(0xFFFFECEF),
    Color(0xFFEFF6FF),
    Color(0xFFFEF3C7),
    Color(0xFFE8F5F1),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIndex = index % _icons.length;
    return Material(
      color: _backgrounds[colorIndex],
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(_icons[colorIndex], color: _colors[colorIndex]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mainText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;

  const _NoResultsView({
    required this.query,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sentiment_dissatisfied_outlined,
              color: AppColors.primaryDark,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'لم نجد نتائج بحث متطابقة!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'ما لقيناش منتجات تطابق "$query". جرّب كلمة مختلفة أو راجع الكتابة.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            height: 1.6,
          ),
        ),
        if (products.isNotEmpty) ...[
          const SizedBox(height: 30),
          const Text(
            'قد يعجبك أيضاً',
            style: TextStyle(
              color: AppColors.mainText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: 175,
                  child: ProductCard(
                    product: product,
                    onTap: () => onProductTap(product),
                    onAddToCart: () => onAddToCart(product),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  final SearchState state;
  final VoidCallback onFilterTap;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;

  const _ResultsView({
    required this.state,
    required this.onFilterTap,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final products = state.results;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'نتائج البحث (${products.length})',
                  style: const TextStyle(
                    color: AppColors.mainText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('تصفية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => onProductTap(product),
                onAddToCart: () => onAddToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
