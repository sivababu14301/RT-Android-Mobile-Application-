import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../screens/categories_screen.dart';
import '../../screens/products/product_list_screen.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Title and View All
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.gold),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
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

            return SizedBox(
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(context, categories[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(initialCategory: category.name),
            ),
          );
        },
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    category.iconData,
                    color: AppColors.gold,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
