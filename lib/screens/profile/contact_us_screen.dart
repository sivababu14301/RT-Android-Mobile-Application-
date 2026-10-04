import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error calling $phoneNumber: $e");
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final formattedNumber = cleanNumber.startsWith('91') ? cleanNumber : '91$cleanNumber';
    final Uri whatsappUri = Uri.parse("https://wa.me/$formattedNumber");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri fallbackUri = Uri.parse("https://api.whatsapp.com/send?phone=$formattedNumber");
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening WhatsApp for $phoneNumber: $e");
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
          'Contact Us',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_outlined,
                      size: 50,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RT Raymaans Tailors',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Custom Fit Tailoring & Bespoke Fashion Support',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 📞 MOBILE NUMBER SECTION
            const Text(
              'CALL US',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_in_talk,
              title: 'Mobile Support',
              subtitle: 'Tap to call directly',
              numbers: ['9444024411'],
              onTapNumber: (num) => _makePhoneCall(num),
              buttonColor: AppColors.gold,
              buttonTextColor: Colors.black,
            ),

            const SizedBox(height: 24),

            // 📱 WHATSAPP SECTION
            const Text(
              'WHATSAPP SUPPORT',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: 'WhatsApp Direct Chat',
              subtitle: 'Tap any number to chat on WhatsApp',
              numbers: ['9786893611', '9585901112'],
              onTapNumber: (num) => _openWhatsApp(num),
              buttonColor: const Color(0xFF25D366), // WhatsApp Green
              buttonTextColor: Colors.white,
            ),

            const SizedBox(height: 24),

            // STORE INFORMATION
            const Text(
              'STORE INFORMATION',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.location_on_outlined, color: AppColors.gold),
                    title: Text('Store Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      'Raymaans Tailors,\nEriyur, Sunchalnatham (PO),\nPennagaram Taluk,\nDharmapuri District – 636810,\nTamil Nadu, India.',
                      style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4),
                    ),
                  ),
                  Divider(color: Colors.white10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: AppColors.gold),
                    title: Text('Working Hours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Monday – Saturday: 9:00 AM – 9:00 PM\nSunday: 10:00 AM – 6:00 PM', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> numbers,
    required Function(String) onTapNumber,
    required Color buttonColor,
    required Color buttonTextColor,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: buttonColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Column(
            children: numbers.map((num) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onTapNumber(num),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Text(
                          num,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            title.contains('WhatsApp') ? 'CHAT' : 'CALL',
                            style: TextStyle(
                              color: buttonTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
