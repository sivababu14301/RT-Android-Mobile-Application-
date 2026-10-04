import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../providers/admin/admin_profile_provider.dart';
import '../../../widgets/admin/profile/profile_avatar.dart';
import '../../../widgets/admin/profile/profile_card.dart';
import '../../../widgets/admin/profile/settings_tile.dart';
import '../../../widgets/admin_management_tile.dart';
import '../offers/admin_offer_list_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'settings_screen.dart';
import '../../auth/login_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
          ),
        ],
      ),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  imageUrl: profile.profilePhoto,
                  onCameraTap: () {},
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: const TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'PERSONAL INFORMATION',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileCard(
                  label: 'Shop Name',
                  value: profile.shopName,
                  icon: Icons.storefront_outlined,
                ),
                ProfileCard(
                  label: 'Phone Number',
                  value: profile.phoneNumber,
                  icon: Icons.phone_outlined,
                ),
                ProfileCard(
                  label: 'Shop Address',
                  value: profile.shopAddress,
                  icon: Icons.location_on_outlined,
                ),
                if (profile.gstNumber != null)
                  ProfileCard(
                    label: 'GST Number',
                    value: profile.gstNumber!,
                    icon: Icons.description_outlined,
                  ),
                const SizedBox(height: 32),
                const Text(
                  'PROMOTIONS MANAGEMENT',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                AdminManagementTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Exclusive Offers',
                  subtitle: 'Manage home screen promotional offers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminOfferListScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'ACCOUNT SETTINGS',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'Preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withAlpha(25), // Fix deprecated withOpacity
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side: const BorderSide(color: Colors.redAccent, width: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'LOGOUT FROM ADMIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
