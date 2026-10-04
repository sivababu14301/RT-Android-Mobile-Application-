import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/payment/payment_button.dart';
import '../customer_main_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String paymentId;
  final String orderId;
  final String method;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.paymentId,
    required this.orderId,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Payment Successful',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your payment has been processed and your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Transaction ID', paymentId),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Order ID', '#$orderId'),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Payment Method', method),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Payment Status', 'Paid', valueColor: Colors.green),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Amount Paid', '₹${amount.toInt()}', valueColor: AppColors.gold, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              PaymentButton(
                text: 'CONTINUE SHOPPING',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
              PaymentButton(
                text: 'VIEW ORDERS',
                isSecondary: true,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerMainScreen(initialIndex: 3)),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
