import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/payment/order_summary_card.dart';
import '../../widgets/payment/payment_method_card.dart';
import '../../widgets/payment/payment_button.dart';
import 'payment_processing_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<PaymentProvider, CartProvider>(
        builder: (context, paymentProvider, cartProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Card
                      const Text(
                        'Order Summary',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      OrderSummaryCard(
                        cartItems: cartProvider.items,
                        subtotal: cartProvider.totalAmount,
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Select Payment Method',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Option 1: Cash on Delivery (COD)
                      PaymentMethodCard(
                        title: 'Cash on Delivery',
                        description: 'Pay when your order is delivered.',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.cod,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.cod),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.payments_outlined, color: Colors.green, size: 22),
                        ),
                      ),

                      // Option 2: Razorpay (Online Payment)
                      PaymentMethodCard(
                        title: 'Razorpay',
                        isRecommended: true,
                        description: 'Pay securely online using Razorpay.',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.razorpay,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.razorpay),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 22),
                        ),
                        extraContent: _buildSupportedMethodsList(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -4)),
                  ],
                ),
                child: PaymentButton(
                  text: paymentProvider.selectedMethod == PaymentMethodType.cod
                      ? 'PLACE COD ORDER'
                      : 'PAY NOW',
                  onPressed: () {
                    if (cartProvider.items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your cart is empty')),
                      );
                      return;
                    }

                    final selected = paymentProvider.selectedMethod;
                    final bool isCod = (selected == PaymentMethodType.cod);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentProcessingScreen(
                          isCod: isCod,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSupportedMethodsList() {
    final methods = ['Google Pay', 'PhonePe', 'Paytm', 'UPI', 'Cards', 'Net Banking'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supported Online Methods:',
          style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: methods.map((m) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
              const SizedBox(width: 4),
              Text(m, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          )).toList(),
        ),
      ],
    );
  }
}
