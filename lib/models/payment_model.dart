import 'package:flutter/widgets.dart';

enum PaymentMethodType { cod, razorpay }

class PaymentMethodModel {
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final IconData icon;

  PaymentMethodModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class OrderSummaryModel {
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double deliveryCharge;
  final double discount;

  OrderSummaryModel({
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.deliveryCharge,
    required this.discount,
  });

  double get subtotal => price * quantity;
  double get grandTotal => subtotal + deliveryCharge - discount;
}
