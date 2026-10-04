import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/logo_widget.dart';
import 'help_support_screen.dart';
import 'contact_us_screen.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_conditions_screen.dart';
import '../info/share_app_screen.dart';
import '../info/rate_app_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
          'About App',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const LogoWidget(size: 120, showText: false),
            const SizedBox(height: 20),
            const Text(
              'RT - Raymaans Tailors',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            const Text(
              'Smart Tailoring & Fashion\nMobile Application',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoRow('Developed by', 'Sivaprasanth B'),
            _buildInfoRow('Email', 'raymaanstailors@gmail.com'),
            _buildInfoRow('Contact', '+91 9444024411'),
            const SizedBox(height: 30),
            
            // Menu Items
            _buildLinkTile(context, 'Privacy Policy', Icons.security_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
            }),
            _buildLinkTile(context, 'Terms & Conditions', Icons.description_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
            }),
            _buildLinkTile(context, 'Share App', Icons.share_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShareAppScreen()));
            }),
            _buildLinkTile(context, 'Rate App', Icons.star_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RateAppScreen()));
            }),
            _buildLinkTile(context, 'Check for Updates', Icons.update, () {}),
            _buildLinkTile(context, 'Contact Us', Icons.contact_support_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
            }),
            _buildLinkTile(context, 'Help & Support', Icons.help_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
            }),
            
            const SizedBox(height: 40),
            const Text(
              '© 2026 Raymaans Tailors',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const Text(
              'All Rights Reserved.',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            leading: Icon(icon, color: AppColors.gold, size: 20),
            title: Text(
              title,
              style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ),
        ),
      ),
    );
  }
}
