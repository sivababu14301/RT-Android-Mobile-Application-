import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/admin/admin_report_provider.dart';

class RevenueDetailsScreen extends StatefulWidget {
  const RevenueDetailsScreen({super.key});

  @override
  State<RevenueDetailsScreen> createState() => _RevenueDetailsScreenState();
}

class _RevenueDetailsScreenState extends State<RevenueDetailsScreen> {
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
        title: const Text('Revenue & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AdminReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (provider.error != null && provider.summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () {
                      final token = context.read<AdminProvider>().admin?.token;
                      if (token != null) provider.fetchAnalytics(token);
                    },
                    child: const Text('Retry', style: TextStyle(color: AppColors.gold)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final token = context.read<AdminProvider>().admin?.token;
              if (token != null) await provider.fetchAnalytics(token);
            },
            color: AppColors.gold,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRevenueSummary(provider.summary),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Sales Summary'),
                  _buildSalesSummaryGrid(provider.salesSummary),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Payment Methods'),
                  _buildPaymentSummary(provider.paymentMethods),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Top Selling Products'),
                  _buildTopSellingProducts(provider.topProducts),
                  const SizedBox(height: 30),
                  _buildReportActions(context, provider),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRevenueSummary(Map<String, dynamic>? summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.05), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Revenue', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '₹${(summary?['totalRevenue'] ?? 0).toInt()}', 
            style: const TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold)
          ),
          const Divider(color: Colors.white10, height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRevenueItem('Today', '₹${(summary?['todayRevenue'] ?? 0).toInt()}'),
              _buildRevenueItem('Weekly', '₹${(summary?['weeklyRevenue'] ?? 0).toInt()}'),
              _buildRevenueItem('Monthly', '₹${(summary?['monthlyRevenue'] ?? 0).toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSalesSummaryGrid(List<dynamic> salesSummary) {
    if (salesSummary.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No sales data', style: TextStyle(color: Colors.white24)),
      ));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: salesSummary.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = salesSummary[index];
        return _buildStatBox(item['_id'] ?? 'Unknown', '${item['count'] ?? 0}');
      },
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(List<dynamic> paymentData) {
    if (paymentData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('No payment records', style: TextStyle(color: Colors.white24))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: paymentData.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 24),
        itemBuilder: (context, index) {
          final item = paymentData[index];
          final method = item['_id'] ?? 'Unknown';
          return _buildPaymentRow(
            method == 'COD' ? 'Cash on Delivery' : method, 
            '₹${(item['total'] ?? 0).toInt()}', 
            method == 'COD' ? Icons.payments_outlined : Icons.account_balance_wallet_outlined
          );
        },
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTopSellingProducts(List<dynamic> topProducts) {
    if (topProducts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No product performance data', style: TextStyle(color: Colors.white24)),
      ));
    }
    return Column(
      children: topProducts.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.star, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${p['totalSold'] ?? 0} units sold', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text('₹${(p['revenue'] ?? 0).toInt()}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildReportActions(BuildContext context, AdminReportProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportReport(context, 'PDF', provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 18),
            label: const Text('EXPORT PDF', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportReport(context, 'Excel', provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.table_view, color: Colors.green, size: 18),
            label: const Text('EXPORT EXCEL', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _exportReport(BuildContext context, String type, AdminReportProvider provider) {
    if (provider.summary == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $type Report for ₹${provider.summary!['totalRevenue'].toInt()} revenue...'),
        backgroundColor: AppColors.gold,
        duration: const Duration(seconds: 2),
      ),
    );
    // In a real app, this would use a package like pdf or excel and share/save the file.
    debugPrint('Exporting $type with ${provider.topProducts.length} top products');
  }
}
