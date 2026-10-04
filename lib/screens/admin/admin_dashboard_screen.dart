import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/admin/admin_provider.dart';
import '../../widgets/admin/dashboard_card.dart';
import '../../widgets/admin/admin_menu_tile.dart';
import '../auth/login_screen.dart';
import 'admin_product_list_screen.dart';
import 'admin_order_management_screen.dart';
import 'revenue_details_screen.dart';
import 'category_management_screen.dart';
import 'fabric_management_screen.dart';
import 'admin_customer_list_screen.dart';
import 'admin_notification_customer_list_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'banner_management_screen.dart';
import 'offers/admin_offer_list_screen.dart';
import 'profile/admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
              );
            },
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.gold),
          ),
          IconButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final stats = provider.stats;
          
          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardStats(),
            color: AppColors.gold,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Overview',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  provider.isLoading && stats == null
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.1,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCustomerListScreen())),
                              child: DashboardCard(
                                title: 'Total Customers',
                                value: '${stats?.totalCustomers ?? 0}',
                                icon: Icons.people_outline,
                                color: Colors.blue,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductListScreen())),
                              child: DashboardCard(
                                title: 'Total Products',
                                value: '${stats?.totalProducts ?? 0}',
                                icon: Icons.inventory_2_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrderManagementScreen())),
                              child: DashboardCard(
                                title: 'Pending Orders',
                                value: '${stats?.pendingOrders ?? 0}',
                                icon: Icons.pending_actions,
                                color: Colors.amber,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RevenueDetailsScreen())),
                              child: DashboardCard(
                                title: 'Total Revenue',
                                value: '₹${stats?.totalRevenue.toInt() ?? 0}',
                                icon: Icons.account_balance_wallet_outlined,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),
                  const Text(
                    'Management Console',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AdminMenuTile(
                    title: 'Product Management',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductListScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Order Management',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrderManagementScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Category Management',
                    icon: Icons.category_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Fabric Management',
                    icon: Icons.texture_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FabricManagementScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Banner Management',
                    icon: Icons.view_carousel_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BannerManagementScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Exclusive Offers',
                    icon: Icons.local_offer_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOfferListScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Customer Measurements',
                    icon: Icons.straighten_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCustomerListScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Business Reports',
                    icon: Icons.analytics_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminReportsScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Notifications & Messages',
                    icon: Icons.message_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminNotificationCustomerListScreen())),
                  ),
                  AdminMenuTile(
                    title: 'Admin Settings',
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsScreen())),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
