class PantMeasurement {
  final String? id;
  final String? userId;
  double waist;
  double hip;
  double thigh;
  double knee;
  double bottom;
  double inseamLength;
  double outseamLength;

  PantMeasurement({
    this.id,
    this.userId,
    this.waist = 0.0,
    this.hip = 0.0,
    this.thigh = 0.0,
    this.knee = 0.0,
    this.bottom = 0.0,
    this.inseamLength = 0.0,
    this.outseamLength = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'measurementType': 'pant',
      'waist': waist,
      'hip': hip,
      'thigh': thigh,
      'knee': knee,
      'bottom': bottom,
      'inseamLength': inseamLength,
      'outseamLength': outseamLength,
    };
  }

  factory PantMeasurement.fromJson(Map<String, dynamic> json) {
    return PantMeasurement(
      id: json['_id'],
      userId: json['userId'],
      waist: (json['waist'] ?? 0.0).toDouble(),
      hip: (json['hip'] ?? 0.0).toDouble(),
      thigh: (json['thigh'] ?? 0.0).toDouble(),
      knee: (json['knee'] ?? 0.0).toDouble(),
      bottom: (json['bottom'] ?? 0.0).toDouble(),
      inseamLength: (json['inseamLength'] ?? 0.0).toDouble(),
      outseamLength: (json['outseamLength'] ?? 0.0).toDouble(),
    );
  }
}
