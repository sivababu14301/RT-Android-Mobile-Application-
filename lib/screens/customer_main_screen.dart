import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/customer_nav_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/bottom_navbar.dart';
import 'home/home_screen.dart';
import 'measurements/measurement_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/my_orders_screen.dart';
import 'profile/profile_screen.dart';

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

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.gold, width: 1.2),
        ),
        title: const Text('Exit App?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to exit RT – Raymaans Tailors?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('EXIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<CustomerNavProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        // If not on Home Tab (index 0), switch back to Home Tab first
        if (navProvider.selectedIndex != 0) {
          context.read<ProductProvider>().resetToAll();
          navProvider.setIndex(0);
        } else {
          // On Root Home Tab: Show exit confirmation dialog
          _showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: navProvider.selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: navProvider.selectedIndex,
          onTap: (index) {
            if (index != 2 || (index == 2 && navProvider.selectedIndex == 2)) {
              context.read<ProductProvider>().resetToAll();
            }
            navProvider.setIndex(index);
          },
        ),
      ),
    );
  }
}
