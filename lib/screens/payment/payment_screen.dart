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
          final double subtotal = cartProvider.subtotal;
          final String formattedAmount = '₹${subtotal.toInt()}';

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
                      const SizedBox(height: 14),
                      OrderSummaryCard(
                        cartItems: cartProvider.items,
                        subtotal: cartProvider.totalAmount,
                      ),
                      const SizedBox(height: 28),

                      // Section 1: Mobile UPI Apps
                      _buildSectionHeader('UPI & Mobile Payment Apps', 'Instant & Secure Payment'),
                      const SizedBox(height: 14),

                      PaymentMethodCard(
                        title: 'Google Pay',
                        description: 'Pay instantly using Google Pay UPI',
                        isRecommended: true,
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.googlePay,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.googlePay),
                        leadingIcon: _buildAppBadge('GPay', Colors.blue, Colors.white),
                        badgeText: 'FASTEST',
                      ),

                      PaymentMethodCard(
                        title: 'PhonePe',
                        description: 'Pay instantly using PhonePe UPI',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.phonePe,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.phonePe),
                        leadingIcon: _buildAppBadge('PhonePe', Colors.deepPurple, Colors.white),
                      ),

                      PaymentMethodCard(
                        title: 'Paytm UPI / Wallet',
                        description: 'Pay using Paytm UPI or Paytm Wallet',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.paytm,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.paytm),
                        leadingIcon: _buildAppBadge('Paytm', Colors.lightBlue, Colors.black),
                      ),

                      PaymentMethodCard(
                        title: 'BHIM / Any UPI ID',
                        description: 'Google Pay, PhonePe, Paytm, CRED, Amazon Pay',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.bhimUpi,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.bhimUpi),
                        leadingIcon: _buildAppBadge('UPI', Colors.orange, Colors.white),
                      ),

                      const SizedBox(height: 24),

                      // Section 2: Cards & Banking
                      _buildSectionHeader('Cards & Banking', 'All Major Cards & Indian Banks'),
                      const SizedBox(height: 14),

                      PaymentMethodCard(
                        title: 'Credit / Debit Card',
                        description: 'Visa, MasterCard, RuPay, Maestro',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.card,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.card),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.credit_card, color: AppColors.gold, size: 20),
                        ),
                      ),

                      PaymentMethodCard(
                        title: 'Net Banking',
                        description: 'SBI, HDFC, ICICI, Axis, Kotak, and more',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.netBanking,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.netBanking),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance, color: AppColors.gold, size: 20),
                        ),
                      ),

                      PaymentMethodCard(
                        title: 'Razorpay Checkout',
                        description: 'Choose any online payment method via Razorpay',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.razorpay,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.razorpay),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 20),
                        ),
                        extraContent: _buildSupportedMethodsList(),
                      ),

                      const SizedBox(height: 24),

                      // Section 3: Cash on Delivery
                      _buildSectionHeader('Pay on Delivery', 'Cash or UPI on Delivery'),
                      const SizedBox(height: 14),

                      PaymentMethodCard(
                        title: 'Cash on Delivery (COD)',
                        description: 'Pay cash or UPI to delivery agent upon arrival.',
                        isSelected: paymentProvider.selectedMethod == PaymentMethodType.cod,
                        onTap: () => paymentProvider.selectMethod(PaymentMethodType.cod),
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.payments_outlined, color: Colors.green, size: 20),
                        ),
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
                  text: _getButtonText(paymentProvider.selectedMethod, formattedAmount),
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
                          preferredMethod: selected,
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAppBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildSupportedMethodsList() {
    final methods = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM UPI', 'Card', 'Net Banking'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supported Gateway Methods:',
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

  String _getButtonText(PaymentMethodType method, String amount) {
    switch (method) {
      case PaymentMethodType.googlePay:
        return 'PAY $amount WITH GOOGLE PAY';
      case PaymentMethodType.phonePe:
        return 'PAY $amount WITH PHONEPE';
      case PaymentMethodType.paytm:
        return 'PAY $amount WITH PAYTM';
      case PaymentMethodType.bhimUpi:
        return 'PAY $amount VIA UPI';
      case PaymentMethodType.card:
        return 'PAY $amount VIA CARD';
      case PaymentMethodType.netBanking:
        return 'PAY $amount VIA NET BANKING';
      case PaymentMethodType.razorpay:
        return 'PAY $amount WITH RAZORPAY';
      case PaymentMethodType.cod:
        return 'PLACE CASH ON DELIVERY ORDER';
    }
  }
}
