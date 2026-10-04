import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/logo_widget.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../auth/login_screen.dart';
import '../customer_main_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Check if user is already logged in and fetch profile
    bool isLoggedIn = await userProvider.checkAuthState();

    if (mounted) {
      if (isLoggedIn) {
        final user = userProvider.user;
        final bool isAdmin = user?.role == 'admin' || user?.email.trim().toLowerCase() == 'admin@raymaanstailors.com';

        if (isAdmin && user != null) {
          Provider.of<AdminProvider>(context, listen: false).setAdmin(
            user.id,
            user.email,
            user.token ?? '',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Luxury Pure Black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(size: 150),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 2,
            ),
            const SizedBox(height: 20),
            const Text(
              'RT - Raymaans Tailors',
              style: TextStyle(
                color: Color(0xCCD4AF37), // Luxury gold with alpha (0.8 * 255 = 204 = CC)
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
