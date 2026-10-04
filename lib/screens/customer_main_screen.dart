import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_nav_provider.dart';
import '../widgets/bottom_navbar.dart';
import 'home/home_screen.dart';
import 'measurements/measurement_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/my_orders_screen.dart';
import 'profile/profile_screen.dart';

import 'package:rt_raymaans_tailors/providers/product_provider.dart';

class CustomerMainScreen extends StatefulWidget {
  final int initialIndex;
  const CustomerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const MeasurementScreen(),
    const ProductListScreen(),
    const MyOrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != 0) {
        context.read<CustomerNavProvider>().setIndex(widget.initialIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<CustomerNavProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) {
          if (index != 2 || (index == 2 && navProvider.selectedIndex == 2)) {
            // When leaving Products page or switching tabs (e.g. returning to Home index 0),
            // reset offer filter, category filter, offerId, and temporary product state
            context.read<ProductProvider>().resetToAll();
          }
          navProvider.setIndex(index);
        },
      ),
    );
  }
}
