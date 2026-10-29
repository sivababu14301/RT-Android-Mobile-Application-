import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

/// Service for managing customer and admin order operations
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
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
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
      
      if (response.statusCode != 201 && response.statusCode != 200) {
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

  Future<Response> cancelOrder(String id, [String? reason]) async {
    try {
      final response = await _dio.put('$id/cancel-request', data: {
        'reason': reason ?? 'Customer requested cancellation'
      });
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> requestOrderCancellation(String id, {String? reason}) async {
    return await cancelOrder(id, reason);
  }

  // Admin APIs
  Future<Response> approveOrderCancellation(String id) async {
    try {
      final response = await _dio.put('$id/approve-cancellation');
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> rejectOrderCancellation(String id, [String? reason]) async {
    try {
      final response = await _dio.put('$id/reject-cancellation', data: {
        'reason': reason ?? 'Processing has started'
      });
      if (response.statusCode != 200) throw _handleError(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

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
