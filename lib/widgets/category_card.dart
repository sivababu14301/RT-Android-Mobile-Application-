import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/api_config.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final IconData? icon;
  final String? imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    this.emoji,
    this.icon,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconContent;
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      iconContent = ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Icon(
            CategoryModel.getIconForName(title),
            color: AppColors.gold,
            size: 28,
          ),
        ),
      );
    } else if (emoji != null) {
      iconContent = Text(
        emoji!,
        style: const TextStyle(fontSize: 28),
      );
    } else {
      iconContent = Icon(
        icon ?? CategoryModel.getIconForName(title),
        color: AppColors.gold,
        size: 28,
      );
    }

    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: iconContent),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
