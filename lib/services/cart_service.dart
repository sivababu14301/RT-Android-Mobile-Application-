import 'package:dio/dio.dart';
import '../config/api_config.dart';

class CartService {
  static String get _baseUrl => '${ApiConfig.baseUrl}cart/';

  final Dio _dio;

  CartService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true,
        )) {
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<Response> getCart() async {
    return await _dio.get('');
  }

  Future<Response> addToCart(String productId, int quantity, {String? size, String? color}) async {
    return await _dio.post('', data: {
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'color': color,
    });
  }

  Future<Response> updateQuantity(String productId, int quantity) async {
    return await _dio.put(productId, data: {
      'quantity': quantity,
    });
  }

  Future<Response> removeFromCart(String productId) async {
    return await _dio.delete(productId);
  }

  Future<Response> clearCart() async {
    return await _dio.delete('');
  }
}
