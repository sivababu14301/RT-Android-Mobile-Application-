class AdminModel {
  final String id;
  final String email;
  final String role;
  final String token;

  AdminModel({
    required this.id,
    required this.email,
    this.role = 'admin',
    required this.token,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
    };
  }
}
