import '../config/api_config.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String? profileImage;
  final String? token;
  final String? role;
  final AddressModel? address;
  final int totalOrders;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.profileImage,
    this.token,
    this.role,
    this.address,
    this.totalOrders = 0,
    this.createdAt,
  });

  String get getProfileImage {
    if (profileImage != null && profileImage!.isNotEmpty) {
      if (profileImage!.startsWith('http')) return profileImage!;
      return '${ApiConfig.baseServerUrl}${profileImage!.startsWith('/') ? '' : '/'}$profileImage';
    }
    return 'https://ui-avatars.com/api/?name=$fullName&background=D4AF37&color=0D0D0D&bold=true&size=256';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '', 
      profileImage: json['profileImage'] ?? json['profilePhoto'],
      token: json['token'],
      role: json['role'],
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
      totalOrders: json['totalOrders'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'profileImage': profileImage,
      'token': token,
      'role': role,
      'address': address?.toJson(),
      'totalOrders': totalOrders,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class AddressModel {
  final String fullName;
  final String mobile;
  final String doorNo;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    required this.fullName,
    required this.mobile,
    required this.doorNo,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });

  String get doorNumber => doorNo;
  String get houseNo => doorNo;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      doorNo: json['doorNo'] ?? json['doorNumber'] ?? json['houseNo'] ?? '',
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'mobile': mobile,
      'doorNumber': doorNo,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  String get formattedAddress {
    final parts = [
      doorNo,
      street,
      area,
      city,
      '${state}${pincode.isNotEmpty ? " - $pincode" : ""}'
    ].where((s) => s.trim().isNotEmpty && s.trim() != '.').toList();
    
    return parts.join(', ');
  }

  String get fullAddress => formattedAddress;
}
