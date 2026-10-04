import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';

class PaymentService {
  static String get _baseUrl => ApiConfig.baseUrl;
  late final Dio _dio;

  PaymentService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  String _handleError(Response response) {
    debugPrint("❌ SERVER PAYMENT ERROR: ${response.statusCode}");
    debugPrint("❌ DATA CONTENT: ${response.data}");

    if (response.data is Map) {
      return response.data['message'] ?? 'Server Error: ${response.statusCode}';
    }
    return 'Server Error: ${response.statusCode}';
  }

  /// Create Razorpay Order on Backend
  Future<Map<String, dynamic>> createRazorpayOrder(double amount, String token) async {
    try {
      const path = 'payment/razorpay/order';
      debugPrint("🚀 [RAZORPAY ORDER CREATING VIA BACKEND]: Amount ₹$amount");

      final response = await _dio.post(
        path,
        data: {
          'amount': amount,
          'currency': 'INR',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        debugPrint("✅ [RAZORPAY ORDER CREATED]: ${response.data['orderId']}");
        return response.data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint("❌ [CREATE RAZORPAY ORDER ERROR]: $e");
      rethrow;
    }
  }

  /// Verify Razorpay Payment Signature on Backend and Finalize Application Order
  Future<OrderModel> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required Map<String, dynamic> orderData,
    required String token,
  }) async {
    try {
      const path = 'payment/razorpay/verify';
      debugPrint("🚀 [RAZORPAY VERIFYING PAYMENT VIA BACKEND]: $razorpayPaymentId");

      final response = await _dio.post(
        path,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'orderData': orderData,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map &&
          response.data['success'] == true) {
        debugPrint("✅ [RAZORPAY PAYMENT VERIFIED & ORDER PLACED]");
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint("❌ [VERIFY RAZORPAY PAYMENT ERROR]: $e");
      rethrow;
    }
  }
}
