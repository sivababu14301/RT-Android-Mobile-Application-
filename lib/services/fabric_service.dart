import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/fabric_model.dart';

class FabricService {
  static String get _baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;

  FabricService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  // Get active fabrics (User side)
  Future<List<FabricModel>> getActiveFabrics() async {
    try {
      final response = await _dio.get('fabrics');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['fabrics'] ?? [];
        return list.map((json) => FabricModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching active fabrics: $e');
      return [];
    }
  }

  // Get all fabrics (Admin side)
  Future<List<FabricModel>> getAllFabrics(String token) async {
    try {
      final response = await _dio.get(
        'admin/fabrics',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['fabrics'] ?? [];
        return list.map((json) => FabricModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching all fabrics: $e');
      return [];
    }
  }

  // Create fabric
  Future<Map<String, dynamic>> addFabric(String name, bool isActive, String token) async {
    try {
      final response = await _dio.post(
        'admin/fabrics',
        data: {'name': name, 'isActive': isActive},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update fabric
  Future<Map<String, dynamic>> updateFabric(String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.put(
        'admin/fabrics/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete fabric
  Future<Map<String, dynamic>> deleteFabric(String id, String token) async {
    try {
      final response = await _dio.delete(
        'admin/fabrics/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
