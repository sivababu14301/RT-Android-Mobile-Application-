import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/product_provider.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  final List<String> _categories = const [
    'Pants',
    'Shirts',
    'T-Shirts',
    'Formal Shirts',
    'Suits',
    'Wedding Wear',
    'Uniforms',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final String selectedCat = productProvider.selectedCategory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Categories Title & View All Action
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
                      productProvider.resetToAll();
                    },
                    child: Text(
                      selectedCat != 'All' ? 'Clear Filter' : 'All Products',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Single Horizontal Scrolling Row of Text-Only Pill Buttons
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final String category = _categories[index];
                  final bool isSelected = (selectedCat.toLowerCase().trim() == category.toLowerCase().trim());

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          productProvider.resetToAll();
                        } else {
                          productProvider.setCategory(category);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : Colors.black,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.gold,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
