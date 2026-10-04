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
      id: json['_id'] ?? '',
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
}
