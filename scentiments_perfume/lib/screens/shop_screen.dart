import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/chat_state.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/scentiments_logo.dart';
import 'chat/chat_screen.dart';
import 'product_detail_screen.dart';

enum ProductSortOption {
  featured,
  priceLowHigh,
  priceHighLow,
  rating,
  nameAZ,
  biggestDiscount,
}

extension ProductSortOptionExtension on ProductSortOption {
  String get label {
    switch (this) {
      case ProductSortOption.featured:
        return 'Featured';
      case ProductSortOption.priceLowHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighLow:
        return 'Price: High to Low';
      case ProductSortOption.rating:
        return 'Highest Rated';
      case ProductSortOption.nameAZ:
        return 'Name: A to Z';
      case ProductSortOption.biggestDiscount:
        return 'Biggest Discount';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductSortOption.featured:
        return Icons.auto_awesome_rounded;
      case ProductSortOption.priceLowHigh:
        return Icons.arrow_upward_rounded;
      case ProductSortOption.priceHighLow:
        return Icons.arrow_downward_rounded;
      case ProductSortOption.rating:
        return Icons.star_rounded;
      case ProductSortOption.nameAZ:
        return Icons.sort_by_alpha_rounded;
      case ProductSortOption.biggestDiscount:
        return Icons.local_offer_rounded;
    }
  }
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductSortOption _currentSort = ProductSortOption.featured;
  bool _isSearchExpanded = false;

  final List<String> categories = const [
    'All',
    'Floral',
    'Woody',
    'Fresh',
    'Oriental',
    'Gourmand',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _sortProducts(List<Product> list) {
    final sorted = List<Product>.from(list);
    switch (_currentSort) {
      case ProductSortOption.featured:
        return sorted;
      case ProductSortOption.priceLowHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        return sorted;
      case ProductSortOption.priceHighLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        return sorted;
      case ProductSortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        return sorted;
      case ProductSortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        return sorted;
      case ProductSortOption.biggestDiscount:
        sorted.sort((a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0));
        return sorted;
    }
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Sorting',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${ProductSortOption.values.length} options',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...ProductSortOption.values.map((sort) {
              final isSelected = _currentSort == sort;
              return InkWell(
                onTap: () {
                  setState(() => _currentSort = sort);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.softGrey : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected ? Border.all(color: AppTheme.darkBluePrimary) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sort.icon,
                        color: isSelected ? AppTheme.darkBluePrimary : AppTheme.darkBlueIcon,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sort.label,
                          style: TextStyle(
                            color: isSelected ? AppTheme.darkBluePrimary : AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: AppTheme.darkBluePrimary, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ShopStateScope.of(context);
    final themeController = ThemeScope.of(context);
    final chatState = ChatStateScope.of(context);
    final products = _sortProducts(shopState.filteredProducts);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ScentimentsLogo(height: 28),
            const SizedBox(width: 8),
            Text(
              'Catalog',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Search - De Guzman',
            icon: Icon(
              _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
              color: AppTheme.darkBlueIcon,
            ),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  shopState.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Product Sorting',
            icon: Icon(Icons.swap_vert_rounded, color: AppTheme.darkBlueIcon),
            onPressed: () => _showSortModal(context),
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppTheme.darkBlueIcon,
            ),
            onPressed: themeController.toggle,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Chats',
                icon: Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.darkBlueIcon),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                ),
              ),
              if (chatState.totalUnread > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.badgeRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${chatState.totalUnread}',
                      style: const TextStyle(
                        color: AppTheme.alwaysWhite,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search Bar Widget (Search - De Guzman)
            if (_isSearchExpanded || shopState.searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppTheme.darkBluePrimary, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkBluePrimary.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppTheme.darkBluePrimary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (val) => shopState.setSearchQuery(val),
                            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search - De Guzman (fragrance, notes, oud...)',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (shopState.searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              shopState.setSearchQuery('');
                            },
                            child: Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Top Header Intro with Row & Column
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scentiments Perfumes',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Haute Parfumerie & Signature Scents',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort badge button
                    GestureDetector(
                      onTap: () => _showSortModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkBluePrimary.withValues(alpha: 0.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(_currentSort.icon, color: AppTheme.darkBlueIcon, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _currentSort.label,
                              style: TextStyle(
                                color: AppTheme.darkBluePrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Category Chips in horizontal ListView
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected =
                        shopState.selectedCategory.toLowerCase() == cat.toLowerCase();

                    return GestureDetector(
                      onTap: () => shopState.setCategory(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.darkBluePrimary : AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.darkBluePrimary : AppTheme.borderSubtle,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.darkBluePrimary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? AppTheme.pureWhite : AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section Title: "Catalog Products"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${shopState.selectedCategory} Fragrances',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.softGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${products.length}',
                            style: TextStyle(
                              color: AppTheme.darkBluePrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Sorting: ${_currentSort.label}',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2-Column Product GridView
            if (products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppTheme.darkBlueIcon),
                      const SizedBox(height: 12),
                      Text(
                        'No matching perfumes found',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          shopState.setSearchQuery('');
                          shopState.setCategory('All');
                        },
                        child: const Text('Reset filters'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      final isFav = shopState.isFavorite(product.id);

                      return ProductCard(
                        product: product,
                        isFavorite: isFav,
                        onFavoriteToggle: () => shopState.toggleFavorite(product.id),
                        onAddToCart: () {
                          shopState.addToCart(product);
                          showAppSnackBar(context, 'Added ${product.name} to Cart');
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
