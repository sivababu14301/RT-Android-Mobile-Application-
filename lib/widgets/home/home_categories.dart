import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../screens/categories_screen.dart';
import '../../screens/products/product_list_screen.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  // Expanded list of 16 categories
  static const List<String> categories = [
    'Pants',
    'Shirts',
    'T-Shirts',
    'Formal Shirts',
    'Jeans',
    'Trousers',
    'Blazers',
    'Suits',
    'Wedding Wear',
    'School Uniforms',
    'College Uniforms',
    'Casual Wear',
    'Traditional Wear',
    'Shorts',
    'Jackets',
    'Accessories',
  ];

  static IconData getGoldClothingIcon(String categoryName) {
    final clean = categoryName.trim().toLowerCase();
    if (clean == 'pants') return Icons.straighten;
    if (clean == 'shirts') return Icons.dry_cleaning_outlined;
    if (clean == 't-shirts') return Icons.checkroom_outlined;
    if (clean == 'formal shirts') return Icons.business_center_outlined;
    if (clean == 'jeans') return Icons.style_outlined;
    if (clean == 'trousers') return Icons.view_agenda_outlined;
    if (clean == 'blazers') return Icons.work_outline;
    if (clean == 'suits') return Icons.military_tech_outlined;
    if (clean == 'wedding wear') return Icons.celebration_outlined;
    if (clean == 'school uniforms') return Icons.badge_outlined;
    if (clean == 'college uniforms') return Icons.school_outlined;
    if (clean == 'casual wear') return Icons.accessibility_new_outlined;
    if (clean == 'traditional wear') return Icons.auto_awesome_outlined;
    if (clean == 'shorts') return Icons.straighten;
    if (clean == 'jackets') return Icons.checkroom;
    if (clean == 'accessories') return Icons.style;
    return Icons.style_outlined;
  }

  @override
  Widget build(BuildContext context) {
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

        // Single Horizontally Scrollable Row of 16 Circular Black Badges (#080808)
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final String category = categories[index];
              final IconData clothingIcon = getGoldClothingIcon(category);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(initialCategory: category),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 82,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large Circular Dark Badge (#080808) with Thin Gold Border (#D4AF37)
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF080808),
                            border: Border.all(
                              color: AppColors.gold,
                              width: 1.3,
                            ),
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
                              clothingIcon,
                              color: AppColors.gold,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Centered White Category Label
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
  }
}
