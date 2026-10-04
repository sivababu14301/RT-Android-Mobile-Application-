import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

class AdminDashboardService {
  static String get _baseUrl => '${ApiConfig.baseUrl}admin/';

  final Dio _dio;

  AdminDashboardService(String token)
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

  Future<Response> getStats() async {
    try {
      return await _dio.get('dashboard');
    } catch (e) {
      debugPrint('AdminDashboardService Error: $e');
      rethrow;
    }
  }
}
