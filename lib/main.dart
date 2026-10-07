import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash/splash_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/admin/admin_provider.dart';
import 'providers/admin/admin_profile_provider.dart';
import 'providers/measurement_provider.dart';
import 'providers/user_provider.dart';
import 'providers/offer_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/razorpay_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/admin/admin_customer_provider.dart';
import 'providers/admin/admin_report_provider.dart';
import 'providers/customer_nav_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/fabric_provider.dart';
import 'services/local_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications Service
  final localNotifService = LocalNotificationService.instance;
  localNotifService.setNavigatorKey(navigatorKey);
  await localNotifService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerNavProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => MeasurementProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RazorpayProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => AdminCustomerProvider()),
        ChangeNotifierProvider(create: (_) => AdminReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FabricProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Raymaans Tailors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF0D0D0D),
          onSurface: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
