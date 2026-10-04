import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../config/app_colors.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/admin/admin_report_provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminProvider>().admin?.token;
      if (token != null) {
        context.read<AdminReportProvider>().fetchAnalytics(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AdminReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
          }

          final summary = provider.summary;

          return RefreshIndicator(
            onRefresh: () async {
              final token = context.read<AdminProvider>().admin?.token;
              if (token != null) {
                await provider.fetchAnalytics(token);
              }
            },
            color: AppColors.gold,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Summary Overview'),
                  const SizedBox(height: 16),
                  _buildSummaryGrid(summary),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Monthly Revenue'),
                  const SizedBox(height: 16),
                  _buildRevenueChart(provider.revenueTrend),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Orders by Category'),
                  const SizedBox(height: 16),
                  _buildCategoryPerformance(provider.salesSummary),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Top Selling Products'),
                  const SizedBox(height: 16),
                  _buildTopProducts(provider.topProducts),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic>? summary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Total Revenue', '₹${summary?['totalRevenue'] ?? 0}', Icons.payments_outlined, Colors.green),
        _buildStatCard('Total Orders', '${summary?['totalOrders'] ?? 0}', Icons.shopping_bag_outlined, Colors.blue),
        _buildStatCard('Pending', '${summary?['pendingOrders'] ?? 0}', Icons.timer_outlined, Colors.amber),
        _buildStatCard('Completed', '${summary?['completedOrders'] ?? 0}', Icons.check_circle_outline, Colors.teal),
        _buildStatCard('Cancelled', '${summary?['cancelledOrders'] ?? 0}', Icons.cancel_outlined, Colors.red),
        _buildStatCard('Customers', '${summary?['totalCustomers'] ?? 0}', Icons.people_outline, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                title,
                style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> data) {
    final List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    // Build a map of month index (1..12) -> total revenue amount
    final Map<int, double> monthlyRevenue = {
      for (int i = 1; i <= 12; i++) i: 0.0
    };

    for (final item in data) {
      if (item['_id'] != null && item['total'] != null) {
        final int monthNum = (item['_id'] as num).toInt();
        if (monthNum >= 1 && monthNum <= 12) {
          monthlyRevenue[monthNum] = (item['total'] as num).toDouble();
        }
      }
    }

    double maxRevenue = 0.0;
    for (final val in monthlyRevenue.values) {
      if (val > maxRevenue) maxRevenue = val;
    }

    final double totalYearRevenue = monthlyRevenue.values.fold(0.0, (a, b) => a + b);
    final int currentMonth = DateTime.now().month;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annual Breakdown (${DateTime.now().year})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total Recorded: ₹${totalYearRevenue.toInt()}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold),
                ),
                child: Text(
                  '${monthNames[currentMonth - 1]}: ₹${(monthlyRevenue[currentMonth] ?? 0).toInt()}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (index) {
                  final int monthNum = index + 1;
                  final double revenue = monthlyRevenue[monthNum] ?? 0.0;
                  final bool isCurrentMonth = monthNum == currentMonth;
                  final double heightFactor = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;
                  final double barHeight = maxRevenue > 0 ? max(6.0, 110.0 * heightFactor) : 6.0;

                  String amountText = '';
                  if (revenue >= 100000) {
                    amountText = '₹${(revenue / 1000).toStringAsFixed(0)}k';
                  } else if (revenue > 0) {
                    amountText = '₹${revenue.toInt()}';
                  }

                  return Container(
                    width: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Amount text above bar
                        SizedBox(
                          height: 18,
                          child: revenue > 0
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    amountText,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 6),
                        // Vertical Bar
                        Container(
                          width: 14,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: revenue > 0
                                ? AppColors.goldGradient
                                : const LinearGradient(
                                    colors: [Colors.white12, Colors.white10],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: BorderRadius.circular(6),
                            border: isCurrentMonth
                                ? Border.all(color: Colors.white, width: 1)
                                : null,
                            boxShadow: revenue > 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Month Label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: isCurrentMonth
                              ? BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(6),
                                )
                              : null,
                          child: Text(
                            monthNames[index],
                            style: TextStyle(
                              color: isCurrentMonth ? Colors.black : (revenue > 0 ? Colors.white : Colors.white38),
                              fontWeight: isCurrentMonth || revenue > 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformance(List<dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No category data available');

    final double maxCount = data.isEmpty
        ? 1.0
        : data.map((e) => (e['count'] as num).toDouble()).reduce(max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: data.map((item) {
          final count = (item['count'] as num).toInt();
          final revenue = (item['revenue'] as num).toInt();
          final progress = maxCount > 0 ? (count / maxCount) : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['_id'] ?? 'Uncategorized',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '$count Orders  •  ₹$revenue',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProducts(List<dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No product data available');

    return Column(
      children: data.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unknown Product',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['totalSold']} units sold',
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${(item['revenue'] as num).toInt()}',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(message, style: const TextStyle(color: Colors.white24)),
      ),
    );
  }
}
