class DashboardStatsModel {
  final int totalCustomers;
  final int totalProducts;
  final int pendingOrders;
  final double totalRevenue;

  DashboardStatsModel({
    required this.totalCustomers,
    required this.totalProducts,
    required this.pendingOrders,
    required this.totalRevenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
