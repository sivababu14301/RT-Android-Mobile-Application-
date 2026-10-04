import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../widgets/payment/payment_button.dart';
import '../customer_main_screen.dart';

class CodOrderConfirmedScreen extends StatelessWidget {
  final OrderModel order;

  const CodOrderConfirmedScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String shortOrderId = order.id.length > 6
        ? order.id.substring(order.id.length - 6).toUpperCase()
        : order.id.toUpperCase();

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
            mainAxisAlignment: _getAlignment(context),
            children: [
              const SizedBox(height: 60),

              // Check Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.gold,
                  size: 80,
                ),
              ),

              const SizedBox(height: 28),

              // Title
              const Text(
                'Order Placed Successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Your order has been placed successfully. Payment will be collected on delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Transaction ID', 'N/A'),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Order ID', '#$shortOrderId'),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Payment Method', 'Cash on Delivery'),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow('Payment Status', 'Pending', valueColor: AppColors.gold),
                    const Divider(color: Colors.white10, height: 28),
                    _buildDetailRow(
                      'Amount to Pay',
                      '₹${order.totalPrice.toInt()}',
                      valueColor: AppColors.gold,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
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
                    MaterialPageRoute(builder: (context) => const CustomerMainScreen(initialIndex: 3)), // Tab 3 is Orders
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

  MainAxisAlignment _getAlignment(BuildContext context) => MainAxisAlignment.center;

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
