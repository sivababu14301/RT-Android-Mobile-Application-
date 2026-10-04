class FabricModel {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FabricModel({
    required this.id,
    required this.name,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory FabricModel.fromJson(Map<String, dynamic> json) {
    return FabricModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isActive': isActive,
    };
  }
}
