import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class RazorpayDetailsCard extends StatelessWidget {
  final double amount;
  const RazorpayDetailsCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://cdn.iconscout.com/icon/free/png-256/free-razorpay-logo-icon-download-in-svg-png-gif-formats--payment-gateway-brand-logos-icons-1399875.png',
                height: 30,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              const Text(
                'Razorpay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, color: Colors.green, size: 14),
                SizedBox(width: 6),
                Text(
                  'SECURE PAYMENT',
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Merchant: RT - Raymaans Tailors',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white10),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Supported Payment Methods:',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              _buildSupportedItem('GPay'),
              _buildSupportedItem('PhonePe'),
              _buildSupportedItem('Paytm'),
              _buildSupportedItem('Cards'),
              _buildSupportedItem('Net Banking'),
              _buildSupportedItem('Wallets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedItem(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.gold, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
