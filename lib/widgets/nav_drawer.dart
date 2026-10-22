import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/api_config.dart';
import '../providers/customer_nav_provider.dart';
import '../providers/user_provider.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/payment/address_screen.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/customer/offers_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/about_app_screen.dart';
import '../screens/auth/login_screen.dart';

import '../providers/notification_provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  ImageProvider _getProfileImageProvider(String? rawImage, String name) {
    if (rawImage != null && rawImage.trim().isNotEmpty) {
      final clean = rawImage.trim();
      if (clean.startsWith('data:image/')) {
        try {
          final base64Str = clean.split(',').last;
          final bytes = base64Decode(base64Str);
          return MemoryImage(bytes);
        } catch (_) {}
      }
      if (clean.startsWith('http://') || clean.startsWith('https://')) {
        return NetworkImage(clean);
      }
      return NetworkImage('${ApiConfig.baseServerUrl}${clean.startsWith('/') ? '' : '/'}$clean');
    }
    return NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=D4AF37&color=0D0D0D&bold=true&size=256');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, NotificationProvider>(
      builder: (context, userProvider, notificationProvider, child) {
        final user = userProvider.user;
        final unreadCount = notificationProvider.unreadCount;

        // Profile image logic
        ImageProvider profileImage = _getProfileImageProvider(
          user?.profileImage ?? user?.getProfileImage,
          user?.fullName ?? 'Guest',
        );

        return Drawer(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              // Drawer Header
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border(
                    bottom: BorderSide(color: AppColors.goldBorder, width: 0.5),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.gold,
                  child: CircleAvatar(
                    radius: 33,
                    backgroundImage: profileImage,
                  ),
                ),
                accountName: Text(
                  user?.fullName ?? 'Guest User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? 'Please login',
                  style: const TextStyle(color: AppColors.grey),
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(context, Icons.home_outlined, 'Home', () {
                      Navigator.pop(context);
                      context.read<CustomerNavProvider>().setIndex(0);
                    }),
                    _buildDrawerItem(context, Icons.person_outline, 'My Profile', () {
                      Navigator.pop(context);
                      context.read<CustomerNavProvider>().setIndex(4);
                    }),
                    _buildDrawerItem(context, Icons.receipt_long_outlined, 'My Orders', () {
                      Navigator.pop(context);
                      context.read<CustomerNavProvider>().setIndex(3);
                    }),
                    _buildDrawerItem(context, Icons.favorite_border, 'Wishlist', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                    }),
                    _buildDrawerItem(context, Icons.straighten_outlined, 'My Measurements', () {
                      Navigator.pop(context);
                      context.read<CustomerNavProvider>().setIndex(1);
                    }),
                    _buildDrawerItem(context, Icons.location_on_outlined, 'Manage Addresses', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen()));
                    }),
                    _buildDrawerItem(context, Icons.notifications_none_outlined, 'Notifications', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                    }, trailing: unreadCount > 0 ? _buildBadge(unreadCount) : null),
                    _buildDrawerItem(context, Icons.local_offer_outlined, 'Exclusive Offers', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OffersScreen()));
                    }),
                    const Divider(color: Colors.white10),
                    _buildDrawerItem(context, Icons.help_outline, 'Help & Support', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                    }),
                    _buildDrawerItem(context, Icons.info_outline, 'About App', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                    }),
                    _buildDrawerItem(context, Icons.logout, 'Logout', () async {
                      await userProvider.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }, color: Colors.redAccent),
                  ],
                ),
              ),
              
              // App Version or Branding at bottom
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.gold, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        onTap();
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
