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

  /// Primary gold outline icon for category
  IconData get iconData => get3IconsForName(name)[0];

  static IconData getIconForName(String categoryName) => get3IconsForName(categoryName)[0];

  /// Returns 3 consistent category-specific gold outline icons
  List<IconData> get category3Icons => get3IconsForName(name);

  /// Returns 3 consistent category-specific clothing product image URLs
  List<String> get category3Images => get3ImagesForName(name);

  static List<IconData> get3IconsForName(String categoryName) {
    final clean = categoryName.trim().toLowerCase();
    if (clean.contains('pant') || clean.contains('trouser') || clean.contains('jean') || clean.contains('paint')) {
      return [Icons.straighten, Icons.style_outlined, Icons.view_agenda_outlined];
    }
    if (clean.contains('t-shirt') || clean.contains('tshirt') || clean.contains('t shirt')) {
      return [Icons.checkroom_outlined, Icons.dry_cleaning_outlined, Icons.fitness_center_outlined];
    }
    if (clean.contains('formal shirt')) {
      return [Icons.business_center_outlined, Icons.badge_outlined, Icons.checkroom_outlined];
    }
    if (clean.contains('shirt')) {
      return [Icons.dry_cleaning_outlined, Icons.checkroom_outlined, Icons.accessibility_new_outlined];
    }
    if (clean.contains('suit')) {
      return [Icons.military_tech_outlined, Icons.work_outline, Icons.checkroom];
    }
    if (clean.contains('wedding') || clean.contains('royal')) {
      return [Icons.celebration_outlined, Icons.auto_awesome_outlined, Icons.diamond_outlined];
    }
    if (clean.contains('uniform')) {
      return [Icons.badge_outlined, Icons.checkroom_outlined, Icons.assignment_ind_outlined];
    }
    return [Icons.style_outlined, Icons.checkroom_outlined, Icons.dry_cleaning_outlined];
  }

  static List<String> get3ImagesForName(String categoryName) {
    final clean = categoryName.trim().toLowerCase();
    if (clean.contains('pant') || clean.contains('trouser') || clean.contains('jean') || clean.contains('paint')) {
      return [
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('t-shirt') || clean.contains('tshirt') || clean.contains('t shirt')) {
      return [
        'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('formal shirt')) {
      return [
        'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('shirt')) {
      return [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1603252109303-2751441dd157?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('suit')) {
      return [
        'https://images.unsplash.com/photo-1594932224828-b4b05a832971?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('wedding') || clean.contains('royal')) {
      return [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1594932224828-b4b05a832971?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?q=80&w=600&auto=format&fit=crop',
      ];
    }
    if (clean.contains('uniform')) {
      return [
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=600&auto=format&fit=crop',
      ];
    }
    return [
      'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=600&auto=format&fit=crop',
    ];
  }
}
