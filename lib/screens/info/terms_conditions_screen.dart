import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Agreement',
              style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'By using the RT – Raymaans Tailors application, you agree to comply with the following terms and conditions.',
              style: TextStyle(color: AppColors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildTermItem('1. Account Usage', 'Users must provide accurate information. Misuse of accounts will result in immediate suspension.'),
            _buildTermItem('2. Tailoring Orders', 'Customized orders are based on the measurements provided by the user. Please ensure accuracy before saving.'),
            _buildTermItem('3. Cancellations', 'Orders can only be cancelled within 2 hours of placement or before tailoring starts.'),
            _buildTermItem('4. Delivery', 'Estimated delivery dates are provided as a guideline. Delays may occur due to logistics or holidays.'),
            _buildTermItem('5. Pricing', 'All prices are subject to change. Final costs including taxes and delivery will be shown at checkout.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
