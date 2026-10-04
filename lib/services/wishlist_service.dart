import 'package:dio/dio.dart';
import '../config/api_config.dart';

class WishlistService {
  static String get _baseUrl => '${ApiConfig.baseUrl}wishlist/';

  final Dio _dio;

  WishlistService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true,
        )) {
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<Response> getWishlist() async {
    return await _dio.get('');
  }

  Future<Response> addToWishlist(String productId) async {
    return await _dio.post(productId);
  }

  Future<Response> removeFromWishlist(String productId) async {
    return await _dio.delete(productId);
  }

  Future<Response> checkWishlist(String productId) async {
    return await _dio.get('check/$productId');
  }
}
