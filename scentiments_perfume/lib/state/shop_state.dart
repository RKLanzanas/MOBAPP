import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/product.dart';

class ShopState extends ChangeNotifier {
  final List<Product> _allProducts = List.from(sampleProducts);
  final List<CartItem> _cartItems = [];
  final Set<String> _wishlistIds = {'p1', 'p3'}; // default pre-favorited items
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Discount (promo code)
  DiscountCode? _appliedDiscount;

  // Payment method
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  String _gcashNumber = '';
  String _selectedBank = supportedBanks.first;
  String _bankAccountName = '';
  final List<OrderRecord> _orders = [];

  List<Product> get allProducts => _allProducts;
  List<CartItem> get cartItems => _cartItems;
  Set<String> get wishlistIds => _wishlistIds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  DiscountCode? get appliedDiscount => _appliedDiscount;
  PaymentMethod get paymentMethod => _paymentMethod;
  String get gcashNumber => _gcashNumber;
  String get selectedBank => _selectedBank;
  String get bankAccountName => _bankAccountName;
  List<OrderRecord> get orders => _orders;

  int get totalCartQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal => _cartItems.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity));

  /// Total amount saved from product sale prices (original price - sale price).
  double get cartSaleSavings => _cartItems.fold(
      0.0, (sum, item) => sum + (item.product.savings * item.quantity));

  /// Peso amount taken off by the applied promo code.
  double get cartDiscount {
    final d = _appliedDiscount;
    if (d == null || _cartItems.isEmpty) return 0.0;
    if (cartSubtotal < d.minSpend) return 0.0;
    return d.discountFor(cartSubtotal);
  }

  // Philippine Pesos: Free shipping on orders ₱3,500 and above, otherwise ₱150 standard nationwide courier
  double get cartShipping {
    if (_cartItems.isEmpty) return 0.0;
    final d = _appliedDiscount;
    if (d != null && d.freeShipping && cartSubtotal >= d.minSpend) return 0.0;
    return cartSubtotal >= 3500.0 ? 0.0 : 150.0;
  }

  double get cartTax => 0.0;
  double get cartTotal =>
      _cartItems.isEmpty ? 0.0 : (cartSubtotal - cartDiscount + cartShipping);

  List<Product> get filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Product> get wishlistProducts {
    return _allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _wishlistIds.contains(productId);
  }

  void toggleFavorite(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  void addToCart(Product product, {String? option, int qty = 1}) {
    final chosenOption = option ?? (product.sizesOrVolumes.isNotEmpty ? product.sizesOrVolumes.first : 'Standard');
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedOption == chosenOption,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += qty;
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: qty,
        selectedOption: chosenOption,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _appliedDiscount = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Discount codes
  // ---------------------------------------------------------------------------

  /// Applies a promo code. Returns an error message, or null on success.
  String? applyDiscountCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return 'Please enter a discount code.';
    DiscountCode? found;
    for (final d in availableDiscountCodes) {
      if (d.code == code) found = d;
    }
    if (found == null) return 'Invalid discount code "$code".';
    if (cartSubtotal < found.minSpend) {
      return '$code requires a minimum spend of ₱${found.minSpend.toStringAsFixed(0)}.';
    }
    _appliedDiscount = found;
    notifyListeners();
    return null;
  }

  void removeDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Payment method (GCash / COD / Bank)
  // ---------------------------------------------------------------------------

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setGcashNumber(String number) {
    _gcashNumber = number.trim();
    notifyListeners();
  }

  void setBankDetails({required String bank, required String accountName}) {
    _selectedBank = bank;
    _bankAccountName = accountName.trim();
    notifyListeners();
  }

  /// Returns an error message when the selected payment method is incomplete.
  String? validatePayment() {
    switch (_paymentMethod) {
      case PaymentMethod.gcash:
        final digits = _gcashNumber.replaceAll(RegExp(r'\D'), '');
        if (!RegExp(r'^09\d{9}$').hasMatch(digits)) {
          return 'Please enter a valid 11-digit GCash number (09XXXXXXXXX).';
        }
        return null;
      case PaymentMethod.bank:
        if (_bankAccountName.isEmpty) return 'Please enter the bank account name.';
        return null;
      case PaymentMethod.cod:
        return null;
    }
  }

  String get paymentDetails {
    switch (_paymentMethod) {
      case PaymentMethod.gcash:
        return _gcashNumber.isEmpty ? 'GCash number not set' : 'GCash • $_gcashNumber';
      case PaymentMethod.bank:
        return _bankAccountName.isEmpty
            ? _selectedBank
            : '$_selectedBank • $_bankAccountName';
      case PaymentMethod.cod:
        return 'Pay cash upon delivery';
    }
  }

  /// Places the order with the selected payment method & discount, then clears
  /// the cart. Returns the created order.
  OrderRecord placeOrder() {
    final order = OrderRecord(
      id: 'BP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      date: DateTime.now(),
      itemCount: totalCartQuantity,
      subtotal: cartSubtotal,
      discount: cartDiscount,
      shipping: cartShipping,
      total: cartTotal,
      paymentMethod: _paymentMethod,
      paymentDetails: paymentDetails,
      discountCode: cartDiscount > 0 || (_appliedDiscount?.freeShipping ?? false)
          ? _appliedDiscount?.code
          : null,
    );
    _orders.insert(0, order);
    _cartItems.clear();
    _appliedDiscount = null;
    notifyListeners();
    return order;
  }
}

// InheritedNotifier to provide ShopState easily throughout the widget tree
class ShopStateScope extends InheritedNotifier<ShopState> {
  const ShopStateScope({
    super.key,
    required ShopState super.notifier,
    required super.child,
  });

  static ShopState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShopStateScope>()!.notifier!;
  }
}
