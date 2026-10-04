class MeasurementModel {
  final String? id;
  final String? userId;
  final String type;
  
  // Shirt measurements
  double? chest;
  double? waist;
  double? shoulder;
  double? sleeveLength;
  double? shirtLength;
  double? neck;
  
  // Pant measurements
  double? pantWaist;
  double? hip;
  double? thigh;
  double? inseam;
  double? pantLength;
  
  // Custom Fit
  Map<String, double>? customMeasurements;
  final DateTime? createdAt;

  MeasurementModel({
    this.id,
    this.userId,
    required this.type,
    this.chest,
    this.waist,
    this.shoulder,
    this.sleeveLength,
    this.shirtLength,
    this.neck,
    this.pantWaist,
    this.hip,
    this.thigh,
    this.inseam,
    this.pantLength,
    this.customMeasurements,
    this.createdAt,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? custom;
    if (json['customMeasurements'] != null && json['customMeasurements'] is Map) {
      custom = {};
      (json['customMeasurements'] as Map).forEach((key, value) {
        if (value is num) {
          custom![key.toString()] = value.toDouble();
        }
      });
    }

    return MeasurementModel(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString(),
      type: json['type']?.toString() ?? 'shirt',
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      shoulder: (json['shoulder'] as num?)?.toDouble(),
      sleeveLength: (json['sleeveLength'] as num?)?.toDouble(),
      shirtLength: (json['shirtLength'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      pantWaist: (json['pantWaist'] as num?)?.toDouble(),
      hip: (json['hip'] as num?)?.toDouble(),
      thigh: (json['thigh'] as num?)?.toDouble(),
      inseam: (json['inseam'] as num?)?.toDouble(),
      pantLength: (json['pantLength'] as num?)?.toDouble(),
      customMeasurements: custom,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
    };
    if (chest != null) data['chest'] = chest;
    if (waist != null) data['waist'] = waist;
    if (shoulder != null) data['shoulder'] = shoulder;
    if (sleeveLength != null) data['sleeveLength'] = sleeveLength;
    if (shirtLength != null) data['shirtLength'] = shirtLength;
    if (neck != null) data['neck'] = neck;
    if (pantWaist != null) data['pantWaist'] = pantWaist;
    if (hip != null) data['hip'] = hip;
    if (thigh != null) data['thigh'] = thigh;
    if (inseam != null) data['inseam'] = inseam;
    if (pantLength != null) data['pantLength'] = pantLength;
    if (customMeasurements != null) data['customMeasurements'] = customMeasurements;
    return data;
  }
}
