import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/chat_state.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/burgis_image.dart';
import '../widgets/scentiments_logo.dart';
import 'chat/chat_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTrendingIndex = 0;

  // Official Top 6 Trending Scentiments Perfumes in Philippine Pesos (₱)
  final List<Map<String, dynamic>> _trendingPerfumes = [
    {
      'title': 'Scentiments No. 1 Royale',
      'price': 2450.0,
      'category': 'Oriental',
      'image': 'assets/images/perfume_1.png',
    },
    {
      'title': 'Scentiments No. 2 Noir',
      'price': 2650.0,
      'category': 'Woody',
      'image': 'assets/images/perfume_2.jpg',
    },
    {
      'title': 'Scentiments No. 3 Azure',
      'price': 1950.0,
      'category': 'Fresh',
      'image': 'assets/images/perfume_3.jpg',
    },
    {
      'title': 'Scentiments No. 4 Menthe',
      'price': 2150.0,
      'category': 'Fresh',
      'image': 'assets/images/perfume_4.png',
    },
    {
      'title': 'Scentiments No. 5 Rouge',
      'price': 2750.0,
      'category': 'Oriental',
      'image': 'assets/images/perfume_5.png',
    },
    {
      'title': 'Scentiments No. 6 Rose',
      'price': 2350.0,
      'category': 'Floral',
      'image': 'assets/images/perfume_6.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final shopState = ShopStateScope.of(context);
    final themeController = ThemeScope.of(context);
    final chatState = ChatStateScope.of(context);
    final featuredPerfume = shopState.allProducts.first;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.pureWhite,
        centerTitle: false,
        title: const ScentimentsLogo(height: 38),
        actions: [
          // Theme toggle
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppTheme.darkBlueIcon,
            ),
            onPressed: themeController.toggle,
          ),
          // Chat with unread badge
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
          // Cart
          IconButton(
            tooltip: 'Shopping Basket',
            icon: Icon(Icons.shopping_basket_outlined, color: AppTheme.darkBlueIcon),
            onPressed: () => widget.onNavigateToTab(2),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Search Pill Bar (Search - De Guzman)
              _buildTopHeader(context, shopState),

              const SizedBox(height: 8),

              // Promotional Discount Highlight Banner
              _buildDiscountPromoBanner(context, shopState),

              const SizedBox(height: 12),

              // Hero Showcase Banner for Scentiments
              _buildHeroShowcase(context, shopState, featuredPerfume),

              const SizedBox(height: 24),

              // Carousel View: Display swipeable scrollable list of featured perfumes
              _buildSectionHeader(
                title: 'Featured Scent Carousel',
                actionLabel: 'View All',
                onAction: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(height: 12),
              _buildCarouselShowcase(context, shopState),

              const SizedBox(height: 24),

              // Popular Perfumes Section with ListView
              _buildSectionHeader(
                title: 'Popular Perfume Bottles',
                actionLabel: 'Shop All',
                onAction: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(height: 12),
              _buildPopularPerfumeList(context, shopState),

              const SizedBox(height: 24),

              // Trending Perfume Notes Section
              _buildSectionHeader(
                title: 'Trending Scents & Aromas',
                actionLabel: 'Explore',
                onAction: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(height: 12),
              _buildTrendingCarousel(context, shopState),
            ],
          ),
        ),
      ),
    );
  }

  // Discount Promo Banner on Home
  Widget _buildDiscountPromoBanner(BuildContext context, ShopState shopState) {
    final isDark = AppTheme.isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF242428), Color(0xFF141416)]
                : [AppTheme.darkBluePrimary, AppTheme.darkBlueSecondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : AppTheme.darkBluePrimary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C30) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded, color: AppTheme.starGold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPECIAL DISCOUNT: USE CODE SCENT10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Get 10% off your entire order • Free shipping on ₱3,500+',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                shopState.applyDiscountCode('SCENT10');
                showAppSnackBar(context, 'Promo code SCENT10 applied to your basket!');
                widget.onNavigateToTab(2);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.starGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(
                    color: Color(0xFF0B192C),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Header with Search Pill (Search - De Guzman)
  Widget _buildTopHeader(BuildContext context, ShopState shopState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkBluePrimary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppTheme.darkBlueIcon,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        shopState.setSearchQuery(val);
                        if (val.isNotEmpty) {
                          widget.onNavigateToTab(1);
                        }
                      },
                      style: TextStyle(color: AppTheme.textDark, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search - De Guzman (perfumes, notes, oud...)',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => widget.onNavigateToTab(1),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkBluePrimary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppTheme.darkBlueIcon,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Notes',
                    style: TextStyle(
                      color: AppTheme.darkBluePrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hero Card with Perfume Showcase Banner
  Widget _buildHeroShowcase(BuildContext context, ShopState shopState, Product product) {
    final bool isFav = shopState.isFavorite(product.id);
    final discount = product.discountPercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBluePrimary.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Perfume Hero Image
            Positioned.fill(
              child: BurgisImage(
                imagePath: product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Subtle gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Top-Left Floating Info Card with Align
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppTheme.starGold),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₱${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkBluePrimary,
                            ),
                          ),
                          if (discount != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-$discount%',
                                style: const TextStyle(
                                  color: AppTheme.alwaysWhite,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top-Right Diagonal Brand Tag with Transform
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.rotate(
                  angle: 0.08,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBluePrimary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkBluePrimary.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded,
                            size: 14, color: AppTheme.starGold),
                        const SizedBox(width: 4),
                        Text(
                          'Scentiments Exclusive',
                          style: TextStyle(
                            color: AppTheme.pureWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Right-Side Floating Actions Pill
            Positioned(
              right: 18,
              top: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/scentiments_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Heart toggle
                    GestureDetector(
                      onTap: () => shopState.toggleFavorite(product.id),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppTheme.darkBluePrimary : AppTheme.darkBlueIcon,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Basket Quick Add
                    GestureDetector(
                      onTap: () {
                        shopState.addToCart(product);
                        showAppSnackBar(context, 'Added ${product.name} to Cart');
                      },
                      child: Icon(
                        Icons.shopping_basket_rounded,
                        color: AppTheme.darkBlueIcon,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Elevated Button
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBluePrimary,
                  foregroundColor: AppTheme.pureWhite,
                  elevation: 6,
                  shadowColor: AppTheme.darkBluePrimary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.starGold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'EXPLORE SCENTIMENTS',
                          style: TextStyle(
                            color: AppTheme.pureWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.pureWhite, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CarouselView: Swipeable list of featured perfumes
  Widget _buildCarouselShowcase(BuildContext context, ShopState shopState) {
    final perfumes = shopState.allProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 190,
        child: CarouselView(
          itemExtent: 280,
          shrinkExtent: 220,
          children: perfumes.map((perfume) {
            final discount = perfume.discountPercent;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: perfume),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkBluePrimary.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BurgisImage(
                          imagePath: perfume.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-$discount% OFF',
                            style: const TextStyle(
                              color: AppTheme.alwaysWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            perfume.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.alwaysWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₱${perfume.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.starGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  perfume.category,
                                  style: const TextStyle(
                                    color: AppTheme.alwaysWhite,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Popular Perfumes Section with ListView
  Widget _buildPopularPerfumeList(BuildContext context, ShopState shopState) {
    final items = shopState.allProducts.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((perfume) {
          final discount = perfume.discountPercent;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkBluePrimary.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppTheme.softGrey,
                    child: BurgisImage(
                      imagePath: perfume.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        perfume.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₱${perfume.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.darkBluePrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (discount != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-$discount%',
                                style: const TextStyle(
                                  color: AppTheme.alwaysWhite,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Text(
                            perfume.category,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    shopState.addToCart(perfume);
                    showAppSnackBar(context, 'Added ${perfume.name} to Cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkBluePrimary,
                    foregroundColor: AppTheme.pureWhite,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_basket_rounded, size: 14, color: AppTheme.pureWhite),
                      const SizedBox(width: 4),
                      Text(
                        'Buy',
                        style: TextStyle(
                          color: AppTheme.pureWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Bottom Trending Carousel with ListView
  Widget _buildTrendingCarousel(BuildContext context, ShopState shopState) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _trendingPerfumes.length,
        itemBuilder: (context, index) {
          final item = _trendingPerfumes[index];
          final bool isSelected = _selectedTrendingIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTrendingIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppTheme.darkBluePrimary : AppTheme.borderSubtle,
                  width: isSelected ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkBluePrimary.withValues(alpha: isSelected ? 0.08 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        color: AppTheme.softGrey,
                        child: BurgisImage(
                          imagePath: item['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '₱${(item['price'] as double).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBluePrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(
                    color: AppTheme.darkBlueAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.darkBlueAccent,
                  size: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
