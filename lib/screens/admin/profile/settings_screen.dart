import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../providers/admin/admin_profile_provider.dart';
import '../../../widgets/admin/profile/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Preferences',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notification Settings',
                onTap: () {},
              ),
              SettingsTile(
                icon: provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'Theme Mode',
                onTap: provider.toggleDarkMode,
                trailing: Switch(
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleDarkMode(),
                  activeColor: AppColors.gold,
                ),
              ),
              SettingsTile(
                icon: Icons.language,
                title: 'Language',
                onTap: () {},
                trailing: const Text(
                  'English',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SUPPORT & LEGAL',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              SettingsTile(
                icon: Icons.contact_support_outlined,
                title: 'Contact Support',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About Application',
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
