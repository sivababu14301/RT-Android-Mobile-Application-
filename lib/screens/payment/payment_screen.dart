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
      backgroundColor: Colors.black,
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
                      
                      // COD
                      PaymentMethodCard(
                        title: 'Cash on Delivery',
                        description: 'Pay when your order is delivered.',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.cod,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.cod),
                      ),
                      
                      // Razorpay
                      PaymentMethodCard(
                        title: 'Razorpay',
                        isRecommended: true,
                        description: 'Secure online payment powered by Razorpay.',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.razorpay,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.razorpay),
                        extraContent: _buildSupportedMethods(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PaymentButton(
                      text: paymentProvider.selectedMethod == PaymentMethodType.cod ? 'PLACE ORDER' : 'PAY NOW',
                      onPressed: () {
                        if (cartProvider.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Your cart is empty')),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentProcessingScreen(
                              isCod: paymentProvider.selectedMethod == PaymentMethodType.cod,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSupportedMethods() {
    final methods = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM UPI', 'Card', 'Net Banking'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supported Methods:',
          style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: methods.map((m) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
              const SizedBox(width: 6),
              Text(m, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          )).toList(),
        ),
      ],
    );
  }
}
