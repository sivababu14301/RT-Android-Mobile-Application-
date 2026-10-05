import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Product Management Features Coming Soon', style: TextStyle(color: Colors.grey)),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          heroTag: 'product_mgmt_fab',
          onPressed: () {},
          backgroundColor: AppColors.gold,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
