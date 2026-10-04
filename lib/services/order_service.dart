import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class OrderService {
  static String get _baseUrl => '${ApiConfig.baseUrl}orders/';

  final Dio _dio;

  OrderService(String token)
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

  String _handleError(Response response) {
    debugPrint("❌ [OrderService] Server Error: ${response.statusCode}");
    debugPrint("❌ [OrderService] Data: ${response.data}");
    if (response.data is Map) {
      return response.data['message'] ?? 'Server Error: ${response.statusCode}';
    }
    return 'Server Error: ${response.statusCode}';
  }

  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('🚀 [OrderService] POST $_baseUrl');
      debugPrint('📦 [OrderService] Body: $orderData');
      
      final response = await _dio.post('', data: orderData);
      
      if (response.statusCode != 201) {
        throw _handleError(response);
      }
      
      debugPrint('✅ [OrderService] Success: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ [OrderService] Exception: $e');
      rethrow;
    }
  }

  Future<Response> getMyOrders() async {
    try {
      final response = await _dio.get('my-orders');
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getOrderById(String id) async {
    try {
      final response = await _dio.get(id);
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> cancelOrder(String id) async {
    try {
      final response = await _dio.put('$id/cancel');
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Admin APIs
  Future<Response> getAllOrders() async {
    try {
      final response = await _dio.get('');
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.put('$id/status', data: {'status': status});
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
