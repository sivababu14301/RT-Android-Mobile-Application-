import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
          'Payment Methods',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved & Available Payment Methods',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 20),

            // Razorpay / Online Payment Card
            _buildPaymentMethodCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Razorpay / Online Payment',
              subtitle: 'UPI, Credit/Debit Cards, Net Banking',
              badgeText: 'ONLINE & SECURE',
              details: [
                'Google Pay, PhonePe, Paytm, BHIM UPI',
                'Visa, Mastercard, RuPay Cards',
                'Net Banking across major banks',
              ],
            ),

            const SizedBox(height: 16),

            // Cash on Delivery Card
            _buildPaymentMethodCard(
              icon: Icons.payments_outlined,
              title: 'Cash on Delivery',
              subtitle: 'Pay when your tailor order arrives',
              badgeText: 'AVAILABLE',
              details: [
                'Pay cash or UPI upon delivery',
                'Inspection upon door delivery available',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required List<String> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Icon(icon, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Column(
            children: details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
