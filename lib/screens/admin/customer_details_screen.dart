import 'package:flutter/material.dart';

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen is deprecated. Use AdminCustomerListScreen.
    // Redirecting for safety.
    return const Scaffold(
      body: Center(child: Text('Deprecated. Use AdminCustomerListScreen', style: TextStyle(color: Colors.white))),
    );
  }
}
