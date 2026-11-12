import 'package:flutter/material.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final VoidCallback onExplore;

  const WishlistScreen({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final shopState = ShopStateScope.of(context);
    final items = shopState.wishlistProducts;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Saved Fragrances'),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.softGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 56,
                        color: AppTheme.darkBlueIcon,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No Saved Perfumes Yet',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any Scentiments perfume to save it for later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onExplore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBluePrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Discover Fragrances',
                        style: TextStyle(color: AppTheme.pureWhite, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
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
            ),
    );
  }
}
