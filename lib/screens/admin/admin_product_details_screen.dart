import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/product_image_slider.dart';
import 'add_edit_product_screen.dart';

class AdminProductDetailsScreen extends StatelessWidget {
  final Product product;
  const AdminProductDetailsScreen({super.key, required this.product});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
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
              final productProvider = context.read<ProductProvider>();
              final userProvider = context.read<UserProvider>();
              final adminProvider = context.read<AdminProvider>();
              final token = adminProvider.admin?.token ?? userProvider.user?.token;

              if (token != null) {
                final success = await productProvider.deleteProduct(product.id, token);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.red),
                  );
                  Navigator.pop(context); // Go back to list
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
              );
            },
            icon: const Icon(Icons.edit, color: AppColors.gold),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSlider(images: product.fullImageUrls),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${product.category}',
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(color: AppColors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('Available Sizes', product.sizes.join(', ')),
                  const SizedBox(height: 16),
                  _buildSection('Available Colors', product.colors.join(', ')),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showDeleteConfirmation(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('DELETE PRODUCT', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('EDIT PRODUCT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }
}
