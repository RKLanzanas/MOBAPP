import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'burgis_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBluePrimary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Image Holder with Badges and Favorite
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.softGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: BurgisImage(
                      imagePath: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Top-left Badges (Category / BadgeText + Discount % off)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, left: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBluePrimary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.darkBluePrimary.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              product.badgeText,
                              style: TextStyle(
                                color: AppTheme.isDark ? Colors.black : Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          if (discount != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeRed,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.badgeRed.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '-$discount%',
                                style: const TextStyle(
                                  color: AppTheme.alwaysWhite,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Top-right: Favorite heart
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 12),
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? AppTheme.darkBluePrimary : AppTheme.darkBlueIcon,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Perfume Details
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scent Family Tag
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.darkBlueAccent.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Product name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppTheme.starGold),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewsCount})',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row: Price and Add To Basket Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₱${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.darkBluePrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.originalPrice != null)
                            Text(
                              '₱${product.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkBluePrimary,
                          foregroundColor: AppTheme.isDark ? Colors.black : Colors.white,
                          elevation: 3,
                          shadowColor: AppTheme.darkBluePrimary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Icon(
                          Icons.shopping_basket_rounded,
                          color: AppTheme.isDark ? Colors.black : Colors.white,
                          size: 15,
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
  }
}
