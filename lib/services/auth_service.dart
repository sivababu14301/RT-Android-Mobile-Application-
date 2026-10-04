import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AuthService {
  static String get _baseUrl => '${ApiConfig.baseUrl}auth/';

  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  String _getServerMessage(Response response) {
    if (response.data is Map) {
      final data = response.data as Map;
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return 'Error: ${response.statusCode}';
  }

  void _logSafeResponse(Response response) {
    debugPrint('--> API URL: ${response.requestOptions.uri}');
    debugPrint('<-- Response Status: ${response.statusCode}');
    
    if (response.data is Map) {
      final safeData = Map<String, dynamic>.from(response.data as Map);
      if (safeData.containsKey('token')) {
        safeData['token'] = '[REDACTED_JWT_TOKEN]';
      }
      if (safeData.containsKey('user') && safeData['user'] is Map) {
        final safeUser = Map<String, dynamic>.from(safeData['user'] as Map);
        if (safeUser.containsKey('password')) {
          safeUser['password'] = '[REDACTED]';
        }
        safeData['user'] = safeUser;
      }
      debugPrint('<-- Response Body: $safeData');
    } else {
      debugPrint('<-- Response Body: ${response.data}');
    }
  }

  Future<Response> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String rememberAccess,
  }) async {
    try {
      final response = await _dio.post('register', data: {
        'name': fullName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'rememberAccess': rememberAccess,
      });

      _logSafeResponse(response);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response;
      } else {
        throw _getServerMessage(response);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _logSafeResponse(e.response!);
      }
      if (e.type == DioExceptionType.connectionError) {
        throw 'Cannot connect to server. Ensure Backend is running.';
      }
      throw e.message ?? 'Network error occurred';
    }
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final String fullUrl = '${_baseUrl}login';
    debugPrint('--> API URL: $fullUrl');
    try {
      final response = await _dio.post('login', data: {
        'email': email,
        'password': password,
      });

      _logSafeResponse(response);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response;
      } else {
        throw _getServerMessage(response);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _logSafeResponse(e.response!);
        throw _getServerMessage(e.response!);
      }
      debugPrint('Auth Login DioException: ${e.message}');
      throw 'Connection failed. Check your network or server.';
    } catch (e) {
      debugPrint('Auth Login Exception: $e');
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await _dio.post('forgot-password', data: {'email': email});
    if (response.statusCode != 200) {
      throw _getServerMessage(response);
    }
  }

  Future<void> verifyRememberAccess(String email, String rememberAccess) async {
    final response = await _dio.post('verify-remember-access', data: {
      'email': email,
      'rememberAccess': rememberAccess,
    });
    if (response.statusCode != 200) {
      throw _getServerMessage(response);
    }
  }

  Future<void> resetPassword(String email, String newPassword, {String? rememberAccess}) async {
    final response = await _dio.post('reset-password', data: {
      'email': email,
      'newPassword': newPassword,
      'password': newPassword,
      'rememberAccess': rememberAccess,
    });
    if (response.statusCode != 200) {
      throw _getServerMessage(response);
    }
  }
}
