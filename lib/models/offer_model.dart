import '../config/api_config.dart';

class OfferModel {
  final String id;
  final String offerName;
  final String discount;
  final String description;
  final String offerImage;
  final String link;
  final String targetType;
  final String category;
  final String categoryId;
  final String productId;
  final List<String> productIds;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isEnabled;

  OfferModel({
    required this.id,
    required this.offerName,
    required this.discount,
    required this.description,
    required this.offerImage,
    this.link = 'Wedding Collection',
    this.targetType = 'category',
    this.category = '',
    this.categoryId = '',
    this.productId = '',
    this.productIds = const [],
    required this.startDateTime,
    required this.endDateTime,
    this.isEnabled = true,
  });

  static String get baseServerUrl => ApiConfig.baseServerUrl;

  String get fullImageUrl {
    if (offerImage.startsWith('http')) return offerImage;
    return '$baseServerUrl${offerImage.startsWith('/') ? '' : '/'}$offerImage';
  }

  OfferStatus get calculatedStatus {
    if (!isEnabled) return OfferStatus.inactive;
    final now = DateTime.now();
    if (now.isBefore(startDateTime)) return OfferStatus.upcoming;
    if (now.isAfter(endDateTime)) return OfferStatus.expired;
    return OfferStatus.active;
  }

  bool get isEffectivelyActive => calculatedStatus == OfferStatus.active;

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    String parsedTargetType = (json['targetType'] ?? '').toString().toLowerCase();
    String parsedCategory = (json['category'] ?? json['categoryName'] ?? json['link'] ?? '').toString().trim();
    String parsedProductId = (json['productId'] ?? '').toString().trim();
    List<String> parsedProductIds = [];
    
    if (json['productIds'] is List) {
      parsedProductIds = (json['productIds'] as List).map((e) => e.toString()).toList();
    } else if (parsedProductId.isNotEmpty) {
      parsedProductIds = [parsedProductId];
    }

    String parsedLink = (json['link'] ?? '').toString().trim();

    if (parsedTargetType.isEmpty) {
      if (parsedLink.startsWith('product:') || parsedProductId.isNotEmpty || parsedProductIds.isNotEmpty) {
        parsedTargetType = 'product';
      } else {
        parsedTargetType = 'category';
      }
    }

    if (parsedTargetType == 'product' && parsedProductId.isEmpty && parsedLink.startsWith('product:')) {
      final pidStr = parsedLink.replaceFirst('product:', '');
      final pids = pidStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (pids.isNotEmpty) {
        parsedProductId = pids.first;
        parsedProductIds = pids;
      }
    }

    return OfferModel(
      id: json['_id'] ?? '',
      offerName: json['title'] ?? json['offerName'] ?? '',
      discount: json['discount'] ?? '',
      description: json['description'] ?? '',
      offerImage: json['image'] ?? json['offerImage'] ?? '',
      link: parsedLink,
      targetType: parsedTargetType,
      category: parsedCategory,
      categoryId: (json['categoryId'] ?? '').toString(),
      productId: parsedProductId,
      productIds: parsedProductIds,
      startDateTime: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDateTime: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      isEnabled: json['isActive'] ?? json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': offerName,
      'discount': discount,
      'description': description,
      'image': offerImage,
      'link': link,
      'targetType': targetType,
      'category': category,
      'categoryId': categoryId,
      'productId': productId,
      'productIds': productIds,
      'startDate': startDateTime.toIso8601String(),
      'endDate': endDateTime.toIso8601String(),
      'isActive': isEnabled,
    };
  }

  OfferModel copyWith({
    String? id,
    String? offerName,
    String? discount,
    String? description,
    String? offerImage,
    String? link,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isEnabled,
  }) {
    return OfferModel(
      id: id ?? this.id,
      offerName: offerName ?? this.offerName,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      offerImage: offerImage ?? this.offerImage,
      link: link ?? this.link,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

enum OfferStatus { active, upcoming, expired, inactive }
