class ShirtMeasurement {
  final String? id;
  final String? userId;
  double chest;
  double waist;
  double shoulder;
  double sleeveLength;
  double shirtLength;
  double neck;
  double cuff;

  ShirtMeasurement({
    this.id,
    this.userId,
    this.chest = 0.0,
    this.waist = 0.0,
    this.shoulder = 0.0,
    this.sleeveLength = 0.0,
    this.shirtLength = 0.0,
    this.neck = 0.0,
    this.cuff = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'measurementType': 'shirt',
      'chest': chest,
      'waist': waist,
      'shoulder': shoulder,
      'sleeveLength': sleeveLength,
      'shirtLength': shirtLength,
      'neck': neck,
      'cuff': cuff,
    };
  }

  factory ShirtMeasurement.fromJson(Map<String, dynamic> json) {
    return ShirtMeasurement(
      id: json['_id'],
      userId: json['userId'],
      chest: (json['chest'] ?? 0.0).toDouble(),
      waist: (json['waist'] ?? 0.0).toDouble(),
      shoulder: (json['shoulder'] ?? 0.0).toDouble(),
      sleeveLength: (json['sleeveLength'] ?? 0.0).toDouble(),
      shirtLength: (json['shirtLength'] ?? 0.0).toDouble(),
      neck: (json['neck'] ?? 0.0).toDouble(),
      cuff: (json['cuff'] ?? 0.0).toDouble(),
    );
  }
}
