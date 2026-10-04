import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/api_config.dart';

class UserService {
  static String get _baseUrl => '${ApiConfig.baseUrl}users/';

  final Dio _dio;

  UserService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true,
        )) {
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  // Helper to handle responses safely and avoid "String index" errors
  String _handleError(Response? response) {
    if (response?.data == null) return 'Connection Error';
    if (response?.data is Map) {
      return response?.data['message'] ?? 'Unknown Error';
    }
    return response?.data.toString() ?? 'Server Error';
  }

  Future<Response> getProfile() async {
    return await _dio.get('profile');
  }

  Future<Response> updateProfile({required String name, required String email, required String mobile}) async {
    debugPrint('PUT REQUEST TO: ${_baseUrl}profile');
    final response = await _dio.put('profile', data: {
      'name': name,
      'email': email,
      'mobile': mobile,
    });
    debugPrint('RESPONSE STATUS: ${response.statusCode}');
    debugPrint('RESPONSE DATA: ${response.data}');

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
    return response;
  }

  // New method for Profile Picture Upload
  Future<Response> uploadProfilePic(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _dio.put('profile/pic', data: formData);
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
    return response;
  }

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    final response = await _dio.put('change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
    return response;
  }

  Future<Response> updateAddress(Map<String, dynamic> addressData) async {
    final response = await _dio.put('address', data: addressData);
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
    return response;
  }

  Future<Response> deleteAddress() async {
    final response = await _dio.delete('address');
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
    return response;
  }
}
