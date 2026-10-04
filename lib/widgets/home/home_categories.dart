import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class CategoryItem {
  final String name;
  final String icon;
  final String imageUrl;

  CategoryItem({required this.name, required this.icon, required this.imageUrl});
}

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CategoryItem> categories = [
      CategoryItem(name: 'Formal Shirts', icon: '👔', imageUrl: 'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=1000&auto=format&fit=crop'),
      CategoryItem(name: 'T-Shirts', icon: '👕', imageUrl: 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=1000&auto=format&fit=crop'),
      CategoryItem(name: 'Formal Pants', icon: '👖', imageUrl: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=1000&auto=format&fit=crop'),
      CategoryItem(name: 'Wedding', icon: '🤵', imageUrl: 'https://images.unsplash.com/photo-1594932224828-b4b05a832971?q=80&w=1000&auto=format&fit=crop'),
      CategoryItem(name: 'School', icon: '🎓', imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=1000&auto=format&fit=crop'),
      CategoryItem(name: 'College', icon: '🎒', imageUrl: 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=1000&auto=format&fit=crop'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Categories',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(categories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 2),
              image: DecorationImage(
                image: NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(35),
                onTap: () {},
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
