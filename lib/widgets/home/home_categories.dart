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

  IconData _getGoldClothingIcon(String category) {
    final clean = category.trim().toLowerCase();
    if (clean.contains('pant') || clean.contains('trouser') || clean.contains('jean')) {
      return Icons.straighten; // Gold Trousers / Waistband
    }
    if (clean.contains('t-shirt') || clean.contains('tshirt')) {
      return Icons.checkroom_outlined; // Gold T-Shirt
    }
    if (clean.contains('formal shirt')) {
      return Icons.business_center_outlined; // Gold Formal Shirt & Tie
    }
    if (clean.contains('shirt')) {
      return Icons.dry_cleaning_outlined; // Gold Casual / Formal Shirt
    }
    if (clean.contains('suit')) {
      return Icons.military_tech_outlined; // Gold Suit / Blazer Lapel
    }
    if (clean.contains('wedding')) {
      return Icons.celebration_outlined; // Gold Wedding Outfit / Tuxedo
    }
    if (clean.contains('uniform')) {
      return Icons.badge_outlined; // Gold Uniform Clothing
    }
    return Icons.style_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final String selectedCat = productProvider.selectedCategory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Categories Title & Clear Filter Action
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
            const SizedBox(height: 12),

            // Single Horizontally Scrollable Row of Large Circular Black Badges with Centered Gold Clothing Icons
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final String category = _categories[index];
                  final bool isSelected = (selectedCat.toLowerCase().trim() == category.toLowerCase().trim());
                  final IconData clothingIcon = _getGoldClothingIcon(category);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          productProvider.resetToAll();
                        } else {
                          productProvider.setCategory(category);
                        }
                      },
                      child: SizedBox(
                        width: 78,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Large Circular Dark Badge (#080808) with Thin Gold Border & Glow
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF080808),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFF0C94A) : AppColors.gold,
                                  width: isSelected ? 2.2 : 1.3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.gold.withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  clothingIcon,
                                  color: isSelected ? const Color(0xFFF0C94A) : AppColors.gold,
                                  size: isSelected ? 32 : 30,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Centered White Category Label
                            Text(
                              category,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? AppColors.gold : Colors.white,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
