import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import 'products/product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
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
          'All Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final List<CategoryModel> categories = categoryProvider.categories.isNotEmpty
              ? categoryProvider.categories
              : [
                  CategoryModel(id: '1', name: 'Pants', description: 'Custom tailored pants, trousers and jeans'),
                  CategoryModel(id: '2', name: 'Shirts', description: 'Custom tailored casual and everyday shirts'),
                  CategoryModel(id: '3', name: 'T-Shirts', description: 'Premium fitted T-shirts and polo shirts'),
                  CategoryModel(id: '4', name: 'Formal Shirts', description: 'Luxury formal dress shirts'),
                  CategoryModel(id: '5', name: 'Suits', description: 'Bespoke tailored suits and blazers'),
                  CategoryModel(id: '6', name: 'Wedding Wear', description: 'Royal wedding tuxedos and ethnic wear'),
                  CategoryModel(id: '7', name: 'Uniforms', description: 'Custom corporate and school uniforms'),
                ];

          return RefreshIndicator(
            onRefresh: () => categoryProvider.fetchCategories(),
            color: AppColors.gold,
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(initialCategory: cat.name),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withValues(alpha: 0.12),
                            border: Border.all(color: AppColors.gold, width: 1.5),
                          ),
                          child: Icon(
                            cat.iconData,
                            color: AppColors.gold,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
