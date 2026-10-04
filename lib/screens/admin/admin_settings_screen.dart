import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../auth/login_screen.dart';
import 'banner_management_screen.dart';
import 'offers/admin_offer_list_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

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
          'Admin Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Promotions & Marketing'),
            _buildSettingTile(
              Icons.view_carousel_outlined,
              'Banner Management',
              'Manage Home Screen Banners',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BannerManagementScreen())),
            ),
            _buildSettingTile(
              Icons.local_offer_outlined,
              'Exclusive Offers',
              'Manage Coupons & Discounts',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOfferListScreen())),
            ),

            _buildSectionHeader('Shop Information'),
            _buildSettingTile(Icons.storefront_outlined, 'Shop Details', 'Name, Logo, Business Type'),
            _buildSettingTile(Icons.access_time_outlined, 'Business Hours', 'Opening & Closing times'),
            
            _buildSectionHeader('Contact & Support'),
            _buildSettingTile(Icons.phone_outlined, 'Contact Details', 'Phone, WhatsApp, Email'),
            _buildSettingTile(Icons.location_on_outlined, 'Shop Address', 'Update physical location'),
            
            _buildSectionHeader('Business Settings'),
            _buildSettingTile(Icons.local_shipping_outlined, 'Delivery Charges', 'Free delivery limit, Charges'),
            _buildSettingTile(Icons.payments_outlined, 'Payment Settings', 'UPI, Bank Details, COD'),
            
            _buildSectionHeader('Security & Legal'),
            _buildSettingTile(Icons.lock_outline, 'Change Password', 'Update login credentials'),
            _buildSettingTile(Icons.security_outlined, 'Privacy Policy', 'Edit app privacy terms'),
            _buildSettingTile(Icons.description_outlined, 'Terms & Conditions', 'Edit user agreement'),
            
            const SizedBox(height: 40),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('LOGOUT FROM ADMIN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.grey, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
      ),
    );
  }
}
