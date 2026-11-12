class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String description;
  final String badgeText;
  final List<String> tags;
  final List<String> sizesOrVolumes;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.description,
    this.badgeText = 'NEW',
    this.tags = const [],
    this.sizesOrVolumes = const ['30ml', '50ml', '100ml'],
  });

  /// Sale discount in percent (e.g. 14 for "-14%"), or null when not on sale.
  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  /// Amount saved per unit compared to the original price.
  double get savings =>
      originalPrice == null ? 0 : (originalPrice! - price).clamp(0, double.infinity).toDouble();
}

class CartItem {
  final Product product;
  int quantity;
  String selectedOption;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedOption,
  });
}

/// Official High-Quality Catalog for "Scentiments" in Philippine Pesos (₱)
final List<Product> sampleProducts = [
  const Product(
    id: 'p1',
    name: 'Scentiments No. 1 - Golden Amber Royale',
    category: 'Oriental',
    price: 2450.00,
    originalPrice: 2850.00,
    rating: 4.9,
    reviewsCount: 148,
    badgeText: 'BESTSELLER',
    imageUrl: 'assets/images/perfume_1.png',
    description: 'An opulent fragrance opening with warm golden amber, wild blossom honey, precious spices, and rich cedarwood housed in a minimalist amber glass bottle.',
    tags: ['Oriental', 'Golden Amber', 'Warm Spice', 'Signature'],
    sizesOrVolumes: ['30ml', '50ml', '100ml'],
  ),
  const Product(
    id: 'p2',
    name: 'Scentiments No. 2 - Matte Noir & Stardust',
    category: 'Woody',
    price: 2650.00,
    originalPrice: 3100.00,
    rating: 4.9,
    reviewsCount: 172,
    badgeText: 'SIGNATURE',
    imageUrl: 'assets/images/perfume_2.jpg',
    description: 'Bold, commanding, and mysterious. Deep smoky birch, dark vetiver, charred oak, and sparkling golden stardust captured in a midnight black flacon.',
    tags: ['Woody', 'Dark Vetiver', 'Intense Noir', 'Gold Dust'],
    sizesOrVolumes: ['50ml', '100ml'],
  ),
  const Product(
    id: 'p3',
    name: 'Scentiments No. 3 - Azure Coast & Sea Minerals',
    category: 'Fresh',
    price: 1950.00,
    originalPrice: 2300.00,
    rating: 4.8,
    reviewsCount: 125,
    badgeText: 'POPULAR',
    imageUrl: 'assets/images/perfume_3.jpg',
    description: 'Pure serenity captured in a crystal azure blue flacon. Crisp Mediterranean sea salt, crushed bergamot, coastal water lilies, and sun-bleached driftwood.',
    tags: ['Fresh', 'Aquatic', 'Sea Minerals', 'Daily Wear'],
    sizesOrVolumes: ['30ml', '50ml', '100ml'],
  ),
  const Product(
    id: 'p4',
    name: 'Scentiments No. 4 - Fraîche Menthe & Radiant Citrus',
    category: 'Fresh',
    price: 2150.00,
    originalPrice: 2550.00,
    rating: 4.9,
    reviewsCount: 98,
    badgeText: 'AROMATIC',
    imageUrl: 'assets/images/perfume_4.png',
    description: 'An invigorating burst of freshly crushed Moroccan spearmint, radiant bergamot, crystalline citrus, and crisp cedar perched upon a glowing pedestal.',
    tags: ['Fresh', 'Crushed Mint', 'Citrus', 'Clean'],
    sizesOrVolumes: ['30ml', '50ml', '100ml'],
  ),
  const Product(
    id: 'p5',
    name: 'Scentiments No. 5 - Rouge Passion & Ruby Oud',
    category: 'Oriental',
    price: 2750.00,
    originalPrice: 3200.00,
    rating: 4.9,
    reviewsCount: 134,
    badgeText: 'EXCLUSIVE',
    imageUrl: 'assets/images/perfume_5.png',
    description: 'Passionate, seductive, and unforgettable. Ruby red berries, damask rose, velvety patchouli, and smoky Cambodian agarwood crowned with a polished chrome cap.',
    tags: ['Oriental', 'Ruby Oud', 'Red Berries', 'Passionate'],
    sizesOrVolumes: ['50ml', '100ml'],
  ),
  const Product(
    id: 'p6',
    name: 'Scentiments No. 6 - Rose Romantique Elixir',
    category: 'Floral',
    price: 2350.00,
    originalPrice: 2800.00,
    rating: 5.0,
    reviewsCount: 186,
    badgeText: 'ROMANTIC',
    imageUrl: 'assets/images/perfume_6.jpg',
    description: 'The essence of eternal romance. Bulgarian rose petals, sparkling lychee, delicate peach nectar, and warm cashmere musk enveloped in floral petals and a satin collar.',
    tags: ['Floral', 'Rose Petals', 'Romantic', 'Delicate'],
    sizesOrVolumes: ['30ml', '50ml', '100ml'],
  ),
];
