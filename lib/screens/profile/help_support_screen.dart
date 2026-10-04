import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import 'faq_screen.dart';
import 'contact_us_screen.dart';
import 'report_issue_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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
          'Help & Support',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            
            _buildSupportTile(
              context,
              title: 'Frequently Asked Questions',
              subtitle: 'Common questions and answers.',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqScreen()),
                );
              },
            ),
            
            _buildSupportTile(
              context,
              title: 'Call Support',
              subtitle: 'Call our customer support team.',
              icon: Icons.phone_outlined,
              onTap: () => _launchUrl('tel:9444024411'),
            ),
            
            _buildSupportTile(
              context,
              title: 'WhatsApp Support',
              subtitle: 'Chat with us on WhatsApp.',
              icon: Icons.chat_bubble_outline,
              onTap: () => _launchUrl('https://wa.me/919585901112'),
            ),
            
            _buildSupportTile(
              context,
              title: 'Email Support',
              subtitle: 'Send us your questions by email.',
              icon: Icons.mail_outline,
              onTap: () => _launchUrl('mailto:raymaanstailors@gmail.com'),
            ),
            
            _buildSupportTile(
              context,
              title: 'Report an Issue',
              subtitle: 'Report bugs or technical problems.',
              icon: Icons.bug_report_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
                );
              },
            ),
            
            const SizedBox(height: 30),
            const Text(
              'Support Hours',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildHoursRow('Monday – Saturday', '9:00 AM – 8:00 PM'),
                  const Divider(color: Colors.white10, height: 30),
                  _buildHoursRow('Sunday', 'Closed', valueColor: Colors.redAccent),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Need More Help?',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              leading: Icon(icon, color: AppColors.gold, size: 28),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white24,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoursRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
