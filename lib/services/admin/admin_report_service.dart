import 'package:dio/dio.dart';
import '../../config/api_config.dart';

class AdminReportService {
  static String get _baseUrl => '${ApiConfig.baseUrl}admin/reports/';

  final Dio _dio;

  AdminReportService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true,
        )) {
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<Response> getSummary() async {
    return await _dio.get('summary');
  }

  Future<Response> getRevenueTrend() async {
    return await _dio.get('revenue-trend');
  }

  Future<Response> getOrdersTrend() async {
    return await _dio.get('orders-trend');
  }

  Future<Response> getTopProducts() async {
    return await _dio.get('top-products');
  }

  Future<Response> getSalesSummary() async {
    return await _dio.get('sales-summary');
  }

  Future<Response> getPaymentMethods() async {
    return await _dio.get('payment-methods');
  }
}
