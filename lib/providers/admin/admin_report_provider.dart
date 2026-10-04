import 'package:flutter/material.dart';
import '../../services/admin/admin_report_service.dart';

class AdminReportProvider with ChangeNotifier {
  Map<String, dynamic>? _summary;
  List<dynamic> _revenueTrend = [];
  List<dynamic> _ordersTrend = [];
  List<dynamic> _topProducts = [];
  List<dynamic> _salesSummary = [];
  List<dynamic> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get summary => _summary;
  List<dynamic> get revenueTrend => _revenueTrend;
  List<dynamic> get ordersTrend => _ordersTrend;
  List<dynamic> get topProducts => _topProducts;
  List<dynamic> get salesSummary => _salesSummary;
  List<dynamic> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnalytics(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = AdminReportService(token);
      
      final results = await Future.wait([
        service.getSummary(),
        service.getSalesSummary(),
        service.getPaymentMethods(),
        service.getTopProducts(),
        service.getRevenueTrend(),
        service.getOrdersTrend(),
      ]);

      // Check for errors and log which endpoint failed
      final endpoints = ['Summary', 'Sales Summary', 'Payment Methods', 'Top Products', 'Revenue Trend', 'Orders Trend'];
      String? firstErrorMessage;

      for (int i = 0; i < results.length; i++) {
        if (results[i].statusCode != 200) {
          final serverMsg = results[i].data is Map ? results[i].data['message'] : 'Status ${results[i].statusCode}';
          debugPrint('❌ Report API Error [${endpoints[i]}]: $serverMsg');
          firstErrorMessage ??= serverMsg;
        }
      }

      if (firstErrorMessage != null) {
        _error = firstErrorMessage;
      } else {
        _summary = results[0].data['data'];
        _salesSummary = results[1].data['data'];
        _paymentMethods = results[2].data['data'];
        _topProducts = results[3].data['data'];
        _revenueTrend = results[4].data['data'];
        _ordersTrend = results[5].data['data'];
      }

    } catch (e) {
      debugPrint('❌ Report Provider Exception: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
