import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../models/category_model.dart';

class CategoryService {
  static String get _baseUrl => '${ApiConfig.baseUrl}categories/';

  late final Dio _dio;

  CategoryService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('');
      debugPrint("CATEGORIES API RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        final List categoriesJson = response.data['categories'];
        return categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<String?> uploadImage(File imageFile, String token) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        'upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['imageUrl'];
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading category image: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> addCategory(Map<String, dynamic> categoryData, String token) async {
    try {
      debugPrint('Adding Category: $categoryData');
      final response = await _dio.post(
        '',
        data: categoryData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> categoryData, String token) async {
    try {
      final response = await _dio.put(
        id,
        data: categoryData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteCategory(String id, String token) async {
    try {
      final response = await _dio.delete(
        id,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
}
