import 'package:flutter/material.dart';

enum PaymentMethod { gcash, cod, bank }

extension PaymentMethodInfo on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.bank:
        return 'Bank Transfer';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.gcash:
        return 'Pay instantly using your GCash wallet';
      case PaymentMethod.cod:
        return 'Pay in cash when your parcel arrives';
      case PaymentMethod.bank:
        return 'Online banking / over-the-counter deposit';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.gcash:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.cod:
        return Icons.payments_rounded;
      case PaymentMethod.bank:
        return Icons.account_balance_rounded;
    }
  }
}

const List<String> supportedBanks = [
  'BDO Unibank',
  'BPI',
  'Metrobank',
  'Landbank',
  'Security Bank',
  'UnionBank',
];

/// A discount / promo code that can be applied in the cart.
class DiscountCode {
  final String code;
  final String description;

  /// Percentage off the subtotal (0.10 = 10%).
  final double percentOff;

  /// Fixed peso amount off the subtotal.
  final double amountOff;
  final bool freeShipping;
  final double minSpend;

  const DiscountCode({
    required this.code,
    required this.description,
    this.percentOff = 0,
    this.amountOff = 0,
    this.freeShipping = false,
    this.minSpend = 0,
  });

  double discountFor(double subtotal) {
    final value = subtotal * percentOff + amountOff;
    return value > subtotal ? subtotal : value;
  }
}

const List<DiscountCode> availableDiscountCodes = [
  DiscountCode(
    code: 'SCENT10',
    description: '10% off your entire order',
    percentOff: 0.10,
  ),
  DiscountCode(
    code: 'BURGIS10',
    description: '10% off your entire order',
    percentOff: 0.10,
  ),
  DiscountCode(
    code: 'WELCOME100',
    description: '₱100 off for new members (min. ₱1,000)',
    amountOff: 100,
    minSpend: 1000,
  ),
  DiscountCode(
    code: 'PAYDAY15',
    description: '15% off orders ₱5,000 and above',
    percentOff: 0.15,
    minSpend: 5000,
  ),
  DiscountCode(
    code: 'FREESHIP',
    description: 'Free nationwide shipping',
    freeShipping: true,
  ),
  DiscountCode(
    code: 'SCENTIMENTS20',
    description: 'Special 20% launch discount for perfume lovers',
    percentOff: 0.20,
    minSpend: 2500,
  ),
];

class OrderRecord {
  final String id;
  final DateTime date;
  final int itemCount;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final PaymentMethod paymentMethod;
  final String paymentDetails;
  final String? discountCode;

  OrderRecord({
    required this.id,
    required this.date,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.paymentMethod,
    required this.paymentDetails,
    this.discountCode,
  });
}
