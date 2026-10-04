import '../config/api_config.dart';

class BannerModel {
  final String id;
  final String title;
  final String image;
  final String link;
  final String category;
  final String categoryId;
  final String targetType;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.link = '',
    this.category = '',
    this.categoryId = '',
    this.targetType = 'category',
    this.isActive = true,
    this.order = 0,
  });

  static String get baseServerUrl => ApiConfig.baseServerUrl;

  String get fullImageUrl {
    if (image.startsWith('http')) return image;
    return '$baseServerUrl${image.startsWith('/') ? '' : '/'}$image';
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String parsedLink = (json['link'] ?? '').toString().trim();
    String parsedCategory = (json['category'] ?? json['categoryName'] ?? parsedLink).toString().trim();
    String parsedCategoryId = (json['categoryId'] ?? '').toString().trim();

    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      link: parsedLink,
      category: parsedCategory,
      categoryId: parsedCategoryId,
      targetType: json['targetType'] ?? 'category',
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'link': link,
      'category': category,
      'categoryId': categoryId,
      'targetType': targetType,
      'isActive': isActive,
      'order': order,
    };
  }
}
