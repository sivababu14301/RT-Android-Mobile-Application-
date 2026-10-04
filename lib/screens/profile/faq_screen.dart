import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

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
          'Frequently Asked Questions',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection('1. Account Questions'),
            _buildFaqItem(
              'How do I create an account?',
              'Tap the Register button, enter your details, and create your account.',
            ),
            _buildFaqItem(
              'How do I reset my password?',
              'Tap "Forgot Password" on the Login screen and follow the instructions.',
            ),
            const SizedBox(height: 24),
            
            _buildCategorySection('2. Orders & Payments'),
            _buildFaqItem(
              'How can I place an order?',
              'Browse products, add items to the cart, proceed to checkout, and complete the payment.',
            ),
            _buildFaqItem(
              'Which payment methods are supported?',
              'Cash on Delivery (COD), UPI, Credit Card, and Debit Card.',
            ),
            const SizedBox(height: 24),

            _buildCategorySection('3. Measurements'),
            _buildFaqItem(
              'How do I save my measurements?',
              'Open the Measurements section, select Shirt or Pant, enter your measurements, and tap Save.',
            ),
            _buildFaqItem(
              'Can I update my measurements later?',
              'Yes, you can edit and update your measurements anytime.',
            ),
            const SizedBox(height: 24),

            _buildCategorySection('4. Delivery Information'),
            _buildFaqItem(
              'How long does delivery take?',
              'Orders are usually delivered within 5–7 business days.',
            ),
            _buildFaqItem(
              'Can I track my order?',
              'Yes, you can track your order from the Order Tracking screen.',
            ),
            const SizedBox(height: 24),

            _buildCategorySection('5. Return & Cancellation Policy'),
            _buildFaqItem(
              'Can I cancel my order?',
              'Orders can be cancelled before tailoring begins.',
            ),
            _buildFaqItem(
              'Can I return customized stitched products?',
              'Customized stitched products cannot be returned unless there is a manufacturing defect.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          brightness: Brightness.dark,
        ),
        child: ExpansionTile(
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.grey,
          title: Text(
            question,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
