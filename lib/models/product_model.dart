import '../config/api_config.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String fabric;
  final List<String> fabrics;
  final double price;
  final int stock;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final bool allowCustomFit;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.fabric,
    this.fabrics = const [],
    required this.price,
    required this.stock,
    required this.rating,
    this.reviewCount = 0,
    required this.images,
    required this.sizes,
    required this.colors,
    this.allowCustomFit = false,
    this.createdAt,
  });

  bool get isCustomFitAvailable {
    final cat = category.toLowerCase().trim();
    if (cat.contains('t-shirt') || cat.contains('tshirt')) {
      return false; // T-Shirts NEVER have Custom Fit
    }
    if (cat == 'shirt' || cat == 'shirts' || cat == 'pant' || cat == 'pants') {
      return true; // Only Shirts and Pants have Custom Fit
    }
    return false;
  }

  /// Check if a category is a Pant product
  bool get isPantProduct => isPantCategory(category);

  static bool isPantCategory(String catName) {
    final clean = catName.trim().toLowerCase();
    return clean.contains('pant') || clean.contains('trouser') || clean.contains('paint');
  }

  /// Map Pant letter sizes (S, M, L, XL, XXL) to numeric waist sizes (32, 34, 36, 38, 40)
  static String mapPantSizeToNumeric(String size) {
    final clean = size.trim().toUpperCase();
    switch (clean) {
      case 'S':
        return '32';
      case 'M':
        return '34';
      case 'L':
        return '36';
      case 'XL':
        return '38';
      case 'XXL':
        return '40';
      default:
        return size.trim();
    }
  }

  /// Map numeric waist sizes back to letter sizes if needed
  static String mapNumericToPantLetter(String numericSize) {
    final clean = numericSize.trim();
    switch (clean) {
      case '32':
        return 'S';
      case '34':
        return 'M';
      case '36':
        return 'L';
      case '38':
        return 'XL';
      case '40':
        return 'XXL';
      default:
        return numericSize.trim();
    }
  }

  /// Returns sizes with Pant legacy letter sizes automatically mapped to numeric waist numbers
  List<String> get displaySizes {
    if (!isPantProduct) return sizes;
    return sizes.map((s) => mapPantSizeToNumeric(s)).toList();
  }

  static String get baseServerUrl => ApiConfig.baseServerUrl;

  static String formatImageUrl(String path) {
    if (path.trim().isEmpty) return '';
    String cleanPath = path.replaceAll('\\', '/').trim();

    // Convert local dev addresses (localhost, 10.0.2.2, wifi IP) to production server URL
    cleanPath = cleanPath
        .replaceAll('http://localhost:5000', ApiConfig.baseServerUrl)
        .replaceAll('https://localhost:5000', ApiConfig.baseServerUrl)
        .replaceAll('http://127.0.0.1:5000', ApiConfig.baseServerUrl)
        .replaceAll('https://127.0.0.1:5000', ApiConfig.baseServerUrl)
        .replaceAll('http://10.0.2.2:5000', ApiConfig.baseServerUrl)
        .replaceAll('https://10.0.2.2:5000', ApiConfig.baseServerUrl)
        .replaceAll('http://10.69.215.137:5000', ApiConfig.baseServerUrl)
        .replaceAll('https://10.69.215.137:5000', ApiConfig.baseServerUrl);

    // Prevent double /api/ in uploads path
    cleanPath = cleanPath.replaceAll('/api/uploads/', '/uploads/');

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    if (cleanPath.startsWith('/uploads/')) {
      return '${ApiConfig.baseServerUrl}$cleanPath';
    }

    if (cleanPath.startsWith('uploads/')) {
      return '${ApiConfig.baseServerUrl}/$cleanPath';
    }

    return '${ApiConfig.baseServerUrl}${cleanPath.startsWith('/') ? '' : '/'}$cleanPath';
  }

  String get imageUrl {
    if (images.isEmpty) return '';
    return formatImageUrl(images[0]);
  }

  List<String> get fullImageUrls {
    if (images.isEmpty) return [];
    return images.map((path) => formatImageUrl(path)).toList();
  }

  String get formattedPrice => '₹${price.toInt()}';

  factory Product.fromJson(Map<String, dynamic> json) {
    final String rawFabric = json['fabric'] ?? '';
    List<String> parsedFabrics = [];
    if (json['fabrics'] != null && json['fabrics'] is List) {
      parsedFabrics = List<String>.from(json['fabrics']);
    } else if (rawFabric.isNotEmpty) {
      parsedFabrics = rawFabric.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    final List<String> parsedSizes = List<String>.from(json['sizes'] ?? []);

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      fabric: rawFabric,
      fabrics: parsedFabrics,
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : (json['image'] != null && json['image'] != '' ? [json['image']] : []),
      sizes: parsedSizes,
      colors: json['colors'] != null 
          ? List<String>.from(json['colors']) 
          : (json['availableColors'] != null ? List<String>.from(json['availableColors']) : []),
      allowCustomFit: json['allowCustomFit'] ?? parsedSizes.contains('Custom Fit') ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
