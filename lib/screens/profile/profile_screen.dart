import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../auth/login_screen.dart';
import '../customer/offers_screen.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_conditions_screen.dart';
import '../measurements/pant_measurement_screen.dart';
import '../measurements/shirt_measurement_screen.dart';
import '../notifications/notification_screen.dart';
import '../orders/my_orders_screen.dart';
import '../orders/reorder_screen.dart';
import '../payment/address_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'about_app_screen.dart';
import 'contact_us_screen.dart';
import 'payment_history_screen.dart';
import 'invoices_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchProfile();
      final token = userProvider.user?.token;
      if (token != null) {
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(token);
        Provider.of<WishlistProvider>(context, listen: false).fetchWishlist(token);
        Provider.of<CartProvider>(context, listen: false).fetchCart(token);
      }
    });
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout Confirmation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to logout from RT Raymaans Tailors?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await userProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userProvider.isLoading && user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : RefreshIndicator(
              onRefresh: () async {
                await userProvider.fetchProfile();
                final token = userProvider.user?.token;
                if (token != null && context.mounted) {
                  await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(token);
                }
              },
              color: AppColors.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ================================================
                    // PROFILE HEADER
                    // ================================================
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.gold,
                      child: CircleAvatar(
                        radius: 49,
                        backgroundImage: NetworkImage(
                          user?.getProfileImage ?? 'https://ui-avatars.com/api/?name=User&background=D4AF37&color=0D0D0D&bold=true&size=256'
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.fullName ?? 'Guest User',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email available',
                      style: const TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    if (user?.mobile != null && user!.mobile.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.mobile,
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gold, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.edit, color: AppColors.gold, size: 16),
                      label: const Text('Edit Profile', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),

                    const SizedBox(height: 20),

                    // ================================================
                    // PERSONAL INFORMATION
                    // ================================================
                    _buildSectionHeader('PERSONAL INFORMATION'),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen())),
                    ),

                    // ================================================
                    // TAILORING
                    // ================================================
                    _buildSectionHeader('TAILORING'),
                    _buildMenuItem(
                      icon: Icons.straighten_outlined,
                      title: 'Shirt Measurements',
                      subtitle: 'Saved shirt tailoring sizes',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShirtMeasurementScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.layers_outlined,
                      title: 'Pant Measurements',
                      subtitle: 'Saved pant tailoring sizes',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantMeasurementScreen())),
                    ),

                    // ================================================
                    // ORDERS & SHOPPING
                    // ================================================
                    _buildSectionHeader('ORDERS & SHOPPING'),
                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
                    ),
                    Consumer<WishlistProvider>(
                      builder: (context, wishlist, child) {
                        final count = wishlist.items.length;
                        return _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          badgeCount: count > 0 ? count : null,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen())),
                        );
                      },
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notifProvider, child) {
                        final count = notifProvider.unreadCount;
                        return _buildMenuItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Notifications',
                          badgeCount: count > 0 ? count : null,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.replay_outlined,
                      title: 'Reorder',
                      subtitle: 'Reorder items from previous orders',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReorderScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.history_outlined,
                      title: 'Order History',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(title: 'Order History'))),
                    ),
                    _buildMenuItem(
                      icon: Icons.cancel_outlined,
                      title: 'Cancelled Orders',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(filterStatus: 'Cancelled', title: 'Cancelled Orders'))),
                    ),

                    // ================================================
                    // PAYMENTS
                    // ================================================
                    _buildSectionHeader('PAYMENTS'),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Methods',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment History',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentHistoryScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.receipt_outlined,
                      title: 'Invoices',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoicesScreen())),
                    ),

                    // ================================================
                    // OFFERS & SUPPORT
                    // ================================================
                    _buildSectionHeader('OFFERS & SUPPORT'),
                    _buildMenuItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Coupons & Offers',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OffersScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: 'Contact Support',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen())),
                    ),

                    // ================================================
                    // ACCOUNT
                    // ================================================
                    _buildSectionHeader('ACCOUNT'),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About Raymaans Tailors',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen())),
                    ),

                    const SizedBox(height: 28),

                    // ================================================
                    // LOGOUT
                    // ================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context, userProvider),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    int? badgeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
