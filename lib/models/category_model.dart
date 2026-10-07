import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.image = '',
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'isActive': isActive,
    };
  }

  /// Selects a smart Material Icon based on category name
  IconData get iconData => getIconForName(name);

  static IconData getIconForName(String categoryName) {
    final clean = categoryName.trim().toLowerCase();
    if (clean.contains('t-shirt') || clean.contains('tshirt')) {
      return Icons.checkroom_outlined;
    }
    if (clean.contains('shirt')) {
      return Icons.dry_cleaning_outlined;
    }
    if (clean.contains('pant') || clean.contains('trouser')) {
      return Icons.straighten;
    }
    if (clean.contains('suit')) {
      return Icons.work_outline;
    }
    if (clean.contains('wedding') || clean.contains('royal')) {
      return Icons.celebration_outlined;
    }
    if (clean.contains('uniform')) {
      return Icons.badge_outlined;
    }
    return Icons.category_outlined;
  }
}
