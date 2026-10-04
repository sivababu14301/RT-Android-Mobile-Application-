import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/category_chip.dart';
import 'add_edit_product_screen.dart';
import 'admin_product_details_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _fetchProducts() {
    context.read<ProductProvider>().fetchProducts();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<ProductProvider>().setCategory(category);
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.grey),
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
    final categoryProvider = context.watch<CategoryProvider>();
    List<String> categories = ['All'];
    if (categoryProvider.categories.isNotEmpty) {
      categories.addAll(categoryProvider.categories.map((c) => c.name));
    } else {
      categories.addAll(['Shirts', 'Pants', 'T-Shirts', 'Suits', 'Wedding Collection', 'Uniforms']);
    }

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
          'Product Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Products: ${provider.products.length}',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: AppColors.gold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catName = categories[index];
                    return CategoryChip(
                      label: catName,
                      isSelected: _selectedCategory == catName,
                      onTap: () => _onCategorySelected(catName),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchProducts(),
                  color: AppColors.gold,
                  child: provider.isLoading && provider.products.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : provider.products.isEmpty
                          ? const Center(child: Text('No products found for this category', style: TextStyle(color: AppColors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.products.length,
                              itemBuilder: (context, index) {
                                final product = provider.products[index];
                                return _buildAdminProductCard(context, product);
                              },
                            ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          );
        },
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildAdminProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminProductDetailsScreen(product: product)),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black,
                width: 80,
                height: 80,
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.black12,
                    child: const Icon(Icons.error, color: AppColors.gold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, product),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
