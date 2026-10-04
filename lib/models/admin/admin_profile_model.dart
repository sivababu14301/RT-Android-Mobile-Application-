class AdminProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String shopName;
  final String shopAddress;
  final String? gstNumber;
  final String? profilePhoto;

  AdminProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.shopName,
    required this.shopAddress,
    this.gstNumber,
    this.profilePhoto,
  });

  AdminProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? shopName,
    String? shopAddress,
    String? gstNumber,
    String? profilePhoto,
  }) {
    return AdminProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      gstNumber: gstNumber ?? this.gstNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}
