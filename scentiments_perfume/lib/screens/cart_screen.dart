import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/burgis_image.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onContinueShopping;

  const CartScreen({super.key, required this.onContinueShopping});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo(ShopState shopState, String code) {
    final error = shopState.applyDiscountCode(code);
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      _promoController.clear();
      showAppSnackBar(context, 'Promo code ${code.toUpperCase()} applied!');
    }
  }

  void _openCheckoutSheet(BuildContext context, ShopState shopState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckoutModal(
        onOrderSuccess: (order) {
          Navigator.pop(ctx);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (successCtx) => _buildSuccessBottomSheet(successCtx, order),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ShopStateScope.of(context);
    final items = shopState.cartItems;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Shopping Basket'),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: AppTheme.darkBlueIcon),
              onPressed: () {
                shopState.clearCart();
                showAppSnackBar(context, 'Basket cleared');
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.softGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 64,
                        color: AppTheme.darkBluePrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Basket is Empty',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our exclusive Scentiments perfumes to fill your fragrance basket.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.onContinueShopping,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBluePrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      child: Text(
                        'Start Shopping',
                        style: TextStyle(color: AppTheme.pureWhite),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    children: [
                      // Cart Item Cards
                      ...items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  color: AppTheme.softGrey,
                                  child: BurgisImage(
                                    imagePath: item.product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.textDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Size: ${item.selectedOption}',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppTheme.darkBluePrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        if (item.product.originalPrice != null) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '₱${(item.product.originalPrice! * item.quantity).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 11,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity modifier
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.softGrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, size: 14, color: AppTheme.darkBlueIcon),
                                      onPressed: () => shopState.updateQuantity(item, -1),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, size: 14, color: AppTheme.darkBlueIcon),
                                      onPressed: () => shopState.updateQuantity(item, 1),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Discount / Promo Code Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_offer_rounded,
                                    size: 18, color: AppTheme.badgeRed),
                                const SizedBox(width: 8),
                                Text(
                                  'Discount & Vouchers',
                                  style: TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (shopState.appliedDiscount != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.softGrey,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.successGreen, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppTheme.successGreen, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CODE: ${shopState.appliedDiscount!.code}',
                                            style: TextStyle(
                                              color: AppTheme.textDark,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            shopState.appliedDiscount!.description,
                                            style: TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: shopState.removeDiscount,
                                      child: const Text('Remove',
                                          style: TextStyle(
                                              color: AppTheme.badgeRed,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _promoController,
                                      textCapitalization: TextCapitalization.characters,
                                      style: TextStyle(color: AppTheme.textDark, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Enter promo code (e.g. SCENT10)',
                                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        isDense: true,
                                        filled: true,
                                        fillColor: AppTheme.backgroundLight,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: AppTheme.borderSubtle),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: AppTheme.borderSubtle),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _applyPromo(shopState, _promoController.text),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.darkBluePrimary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(
                                          color: AppTheme.pureWhite,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap a code to apply discount:',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: availableDiscountCodes.take(4).map((dc) {
                                  return ActionChip(
                                    label: Text(
                                      dc.code,
                                      style: TextStyle(
                                        color: AppTheme.darkBluePrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    backgroundColor: AppTheme.softGrey,
                                    side: BorderSide(color: AppTheme.borderSubtle),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onPressed: () => _applyPromo(shopState, dc.code),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Payment Method Preview Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.softGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(shopState.paymentMethod.icon,
                                  color: AppTheme.darkBlueIcon, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment: ${shopState.paymentMethod.label}',
                                    style: TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    shopState.paymentDetails,
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _openCheckoutSheet(context, shopState),
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  color: AppTheme.darkBlueAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkBluePrimary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummaryRow('Subtotal', '₱${shopState.cartSubtotal.toStringAsFixed(2)}'),
                      if (shopState.cartDiscount > 0) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Promo Discount (${shopState.appliedDiscount?.code})',
                          '-₱${shopState.cartDiscount.toStringAsFixed(2)}',
                          isDiscount: true,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Shipping Fee',
                        shopState.cartShipping == 0 ? 'FREE' : '₱${shopState.cartShipping.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Estimated Tax', '₱0.00 (VAT Inclusive)'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppTheme.borderSubtle),
                      ),
                      _buildSummaryRow(
                        'Total',
                        '₱${shopState.cartTotal.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                      const SizedBox(height: 18),

                      // Checkout button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _openCheckoutSheet(context, shopState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkBluePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check Out (${shopState.paymentMethod.label})',
                                style: TextStyle(
                                  color: AppTheme.pureWhite,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: AppTheme.pureWhite, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? AppTheme.textDark
                : (isDiscount ? AppTheme.successGreen : AppTheme.textMuted),
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? AppTheme.darkBluePrimary
                : (isDiscount ? AppTheme.successGreen : AppTheme.textDark),
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBottomSheet(BuildContext context, OrderRecord order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.softGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: AppTheme.darkBluePrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order Placed Successfully!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${order.id} • Check out - Burgos/Dael',
            style: TextStyle(color: AppTheme.darkBlueAccent, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Payment Method', order.paymentMethod.label),
                const SizedBox(height: 6),
                _buildReceiptRow('Payment Details', order.paymentDetails),
                if (order.discountCode != null) ...[
                  const SizedBox(height: 6),
                  _buildReceiptRow('Promo Code', order.discountCode!),
                  const SizedBox(height: 6),
                  _buildReceiptRow('Discount', '-₱${order.discount.toStringAsFixed(2)}'),
                ],
                const SizedBox(height: 6),
                _buildReceiptRow('Shipping', order.shipping == 0 ? 'FREE' : '₱${order.shipping.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _buildReceiptRow('Total Amount', '₱${order.total.toStringAsFixed(2)}', isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Thank you for shopping with Scentiments. Your parcel will arrive in 2-3 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onContinueShopping();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBluePrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Back to Home',
                style: TextStyle(color: AppTheme.pureWhite, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.darkBluePrimary : AppTheme.textDark,
            fontSize: isBold ? 15 : 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Checkout Bottom Sheet: Select payment method (GCash, COD, Bank), configure details, and place order.
class _CheckoutModal extends StatefulWidget {
  final Function(OrderRecord) onOrderSuccess;

  const _CheckoutModal({required this.onOrderSuccess});

  @override
  State<_CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<_CheckoutModal> {
  final TextEditingController _gcashController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  String _selectedBank = supportedBanks.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = ShopStateScope.of(context);
      _gcashController.text = shop.gcashNumber;
      _bankAccountController.text = shop.bankAccountName;
      _selectedBank = shop.selectedBank;
    });
  }

  @override
  void dispose() {
    _gcashController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  void _submitOrder(ShopState shop) {
    if (shop.paymentMethod == PaymentMethod.gcash) {
      shop.setGcashNumber(_gcashController.text);
    } else if (shop.paymentMethod == PaymentMethod.bank) {
      shop.setBankDetails(bank: _selectedBank, accountName: _bankAccountController.text);
    }

    final error = shop.validatePayment();
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }

    final order = shop.placeOrder();
    widget.onOrderSuccess(order);
  }

  Widget _buildPaymentDetailFields(ShopState shop) {
    if (shop.paymentMethod == PaymentMethod.gcash) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GCash Mobile Number',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _gcashController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
            decoration: AppTheme.inputDecoration(
              hint: '09XXXXXXXXX',
              icon: Icons.phone_android_rounded,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You will receive a GCash Express Checkout prompt upon placement.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      );
    }

    if (shop.paymentMethod == PaymentMethod.bank) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Bank',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedBank,
            dropdownColor: AppTheme.pureWhite,
            style: TextStyle(color: AppTheme.textDark, fontSize: 13),
            decoration: AppTheme.inputDecoration(
              hint: 'Choose your bank',
              icon: Icons.account_balance_rounded,
            ),
            items: supportedBanks
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _selectedBank = v ?? _selectedBank),
          ),
          const SizedBox(height: 10),
          Text(
            'Depositor / Account Name',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bankAccountController,
            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
            decoration: AppTheme.inputDecoration(
              hint: 'Juan Dela Cruz',
              icon: Icons.person_outline_rounded,
            ),
          ),
        ],
      );
    }

    // Default: COD
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.softGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.starGold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cash on Delivery is available nationwide. Please prepare exact amount upon delivery.',
              style: TextStyle(color: AppTheme.textDark, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = ShopStateScope.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
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
                    'Select Payment Method',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Check out - Burgos/Dael',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Method Options: GCash / COD / Bank
              ...PaymentMethod.values.map((method) {
                final isSelected = shop.paymentMethod == method;
                return GestureDetector(
                  onTap: () => setState(() => shop.setPaymentMethod(method)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.softGrey : AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.darkBluePrimary : AppTheme.borderSubtle,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method.icon,
                          color: isSelected ? AppTheme.darkBluePrimary : AppTheme.darkBlueIcon,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.label,
                                style: TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                method.description,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<PaymentMethod>(
                          value: method,
                          // ignore: deprecated_member_use
                          groupValue: shop.paymentMethod,
                          activeColor: AppTheme.darkBluePrimary,
                          // ignore: deprecated_member_use
                          onChanged: (m) => setState(() => shop.setPaymentMethod(m!)),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Additional Details based on payment method
              _buildPaymentDetailFields(shop),

              const SizedBox(height: 20),

              // Total to pay and Confirm Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total to pay', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      Text(
                        '₱${shop.cartTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.darkBluePrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _submitOrder(shop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBluePrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Place Order',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
