import 'package:dio/dio.dart';
import '../../config/api_config.dart';

class AdminCustomerService {
  static String get _baseUrl => '${ApiConfig.baseUrl}admin/';

  final Dio _dio;

  AdminCustomerService(String token)
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

  Future<Response> getCustomers() async {
    return await _dio.get('customers');
  }

  Future<Response> getCustomerById(String id) async {
    return await _dio.get('customers/$id');
  }

  Future<Response> getCustomerOrders(String id) async {
    return await _dio.get('customers/$id/orders');
  }

  Future<Response> getCustomerMeasurements(String id) async {
    return await _dio.get('customers/$id/measurements');
  }
}
