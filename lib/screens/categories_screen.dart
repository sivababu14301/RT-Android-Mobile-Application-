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
  final List<CategoryModel> _standard7Categories = [
    CategoryModel(id: '1', name: 'Pants', description: 'Custom tailored pants, trousers and jeans'),
    CategoryModel(id: '2', name: 'Shirts', description: 'Custom tailored casual and everyday shirts'),
    CategoryModel(id: '3', name: 'T-Shirts', description: 'Premium fitted T-shirts and polo shirts'),
    CategoryModel(id: '4', name: 'Formal Shirts', description: 'Luxury formal dress shirts'),
    CategoryModel(id: '5', name: 'Suits', description: 'Bespoke tailored suits and blazers'),
    CategoryModel(id: '6', name: 'Wedding Wear', description: 'Royal wedding tuxedos and ethnic wear'),
    CategoryModel(id: '7', name: 'Uniforms', description: 'Custom corporate and school uniforms'),
  ];

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
              : _standard7Categories;

          return RefreshIndicator(
            onRefresh: () => categoryProvider.fetchCategories(),
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final List<IconData> icons3 = cat.category3Icons;
                final List<String> images3 = cat.category3Images;

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
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header Row
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withValues(alpha: 0.12),
                                border: Border.all(color: AppColors.gold, width: 1.5),
                              ),
                              child: Icon(
                                cat.iconData,
                                color: AppColors.gold,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat.description,
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 3 Category Visual Thumbnails Row
                        Row(
                          children: List.generate(3, (i) {
                            final String imgUrl = i < images3.length ? images3[i] : '';
                            final IconData icon = i < icons3.length ? icons3[i] : Icons.checkroom_outlined;

                            return Expanded(
                              child: Container(
                                height: 75,
                                margin: EdgeInsets.only(right: i < 2 ? 8.0 : 0.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                  color: Colors.black26,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: AppColors.gold.withValues(alpha: 0.1),
                                            child: Icon(icon, color: AppColors.gold, size: 28),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 6,
                                        bottom: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.gold, width: 0.8),
                                          ),
                                          child: Icon(icon, color: AppColors.gold, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
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
