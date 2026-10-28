import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../screens/categories_screen.dart';
import '../../screens/products/product_list_screen.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  // Top 7 featured categories for Home page
  static const List<String> topCategories = [
    'Shirts',
    'Pants',
    'T-Shirts',
    'Formal Shirts',
    'Jeans',
    'Suits',
    'Blazers',
  ];

  // Full list of 16 categories for the full Categories Screen
  static const List<String> allCategories = [
    'Shirts',
    'Pants',
    'T-Shirts',
    'Formal Shirts',
    'Jeans',
    'Suits',
    'Blazers',
    'Trousers',
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
    if (clean == 'shirts') return Icons.dry_cleaning_outlined;
    if (clean == 'pants') return Icons.straighten;
    if (clean == 't-shirts') return Icons.checkroom_outlined;
    if (clean == 'formal shirts') return Icons.business_center_outlined;
    if (clean == 'jeans') return Icons.style_outlined;
    if (clean == 'suits') return Icons.military_tech_outlined;
    if (clean == 'blazers') return Icons.work_outline;
    if (clean == 'trousers') return Icons.view_agenda_outlined;
    if (clean == 'wedding wear') return Icons.celebration_outlined;
    if (clean == 'school uniforms') return Icons.badge_outlined;
    if (clean == 'college uniforms') return Icons.school_outlined;
    if (clean == 'casual wear') return Icons.accessibility_new_outlined;
    if (clean == 'traditional wear') return Icons.auto_awesome_outlined;
    if (clean == 'shorts') return Icons.straighten;
    if (clean == 'jackets') return Icons.checkroom;
    if (clean == 'accessories') return Icons.style;
    return Icons.checkroom_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // 7 categories + 1 "More" item
    final int itemCount = topCategories.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Categories Title & View All
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontally Scrollable Row of 7 Category Circles + 1 "More" Circle
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final bool isMore = index == topCategories.length;
              final String title = isMore ? 'More' : topCategories[index];
              final IconData icon = isMore ? Icons.grid_view : getGoldClothingIcon(title);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (isMore) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListScreen(initialCategory: title),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular Icon Container (#080808) with Gold Border (#D4AF37)
                        Container(
                          width: 68,
                          height: 68,
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
                              icon,
                              color: AppColors.gold,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // White Label
                        Text(
                          title,
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
