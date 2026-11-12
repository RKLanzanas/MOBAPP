import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/burgis_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedOption;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.product.sizesOrVolumes.isNotEmpty
        ? widget.product.sizesOrVolumes.first
        : 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ShopStateScope.of(context);
    final isFav = shopState.isFavorite(widget.product.id);
    final discount = widget.product.discountPercent;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Image & Floating Navigation
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppTheme.pureWhite,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.darkBlueIcon,
                    size: 18,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => shopState.toggleFavorite(widget.product.id),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppTheme.darkBluePrimary : AppTheme.darkBlueIcon,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    showAppSnackBar(context, 'Product link copied to clipboard!');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.share_outlined,
                      color: AppTheme.darkBlueIcon,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BurgisImage(
                    imagePath: widget.product.imageUrl,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge & Category & Discount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBluePrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.product.badgeText,
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (discount != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeRed,
                                borderRadius: BorderRadius.circular(12),
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
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.starGold, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating.toString(),
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.product.reviewsCount} reviews)',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pricing & Discount Savings
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₱${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.darkBluePrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (widget.product.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '₱${widget.product.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Save ₱${widget.product.savings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Option Selector (Sizes or Volumes)
                  Text(
                    'Select Size / Volume',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: widget.product.sizesOrVolumes.map((opt) {
                      final isSelected = _selectedOption == opt;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOption = opt;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.darkBluePrimary : AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.darkBluePrimary : AppTheme.borderSubtle,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            opt,
                            style: TextStyle(
                              color: isSelected ? AppTheme.pureWhite : AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.softGrey,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, size: 16, color: AppTheme.darkBlueIcon),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, size: 16, color: AppTheme.darkBlueIcon),
                              onPressed: () {
                                setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Fragrance Profile & Notes',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.product.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.softGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppTheme.darkBlueSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Add to Cart Bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBluePrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₱${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.darkBluePrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  shopState.addToCart(
                    widget.product,
                    option: _selectedOption,
                    qty: _quantity,
                  );
                  Navigator.pop(context);
                  showAppSnackBar(
                    context,
                    'Added $_quantity × ${widget.product.name} to Cart',
                  );
                },
                icon: Icon(
                  Icons.shopping_basket_rounded,
                  color: AppTheme.isDark ? Colors.black : Colors.white,
                ),
                label: Text(
                  'Add to Basket',
                  style: TextStyle(
                    color: AppTheme.isDark ? Colors.black : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBluePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
