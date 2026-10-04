import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Introduction',
              style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'At Raymaans Tailors, we value your privacy. This policy explains how we collect and protect your personal information.',
              style: TextStyle(color: AppColors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildPolicyItem('1. Data Collection', 'We collect your name, email, phone number, and body measurements to provide custom tailoring services.'),
            _buildPolicyItem('2. Account Security', 'Your account credentials are encrypted and stored securely to prevent unauthorized access.'),
            _buildPolicyItem('3. Payment Security', 'All payments are processed through secure gateways. We do not store your full card details on our servers.'),
            _buildPolicyItem('4. Customer Privacy', 'We do not sell or share your personal data with third-party advertisers for marketing purposes.'),
            _buildPolicyItem('5. Information Usage', 'Your information is used to fulfill orders, provide customer support, and improve our services.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String title, String content) {
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
