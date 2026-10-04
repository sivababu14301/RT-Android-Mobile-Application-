class AddressModel {
  final String? id;
  final String fullName;
  final String mobile;
  final String houseNo;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;

  AddressModel({
    this.id,
    required this.fullName,
    required this.mobile,
    required this.houseNo,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'mobile': mobile,
      'houseNo': houseNo,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      fullName: json['fullName'],
      mobile: json['mobile'],
      houseNo: json['houseNo'],
      street: json['street'],
      area: json['area'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      landmark: json['landmark'],
    );
  }

  String get fullAddress {
    final parts = [
      houseNo,
      street,
      area,
      city,
      '${state}${pincode.isNotEmpty ? " - $pincode" : ""}'
    ].where((s) => s.trim().isNotEmpty && s.trim() != '.').toList();
    
    return parts.join(', ');
  }
}
