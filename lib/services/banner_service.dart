import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../models/banner_model.dart';

class BannerService {
  static String get _baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;

  BannerService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dio.get('banners');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List bannersJson = response.data['banners'] ?? [];
        return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addBanner(Map<String, dynamic> bannerData, String token) async {
    try {
      final response = await _dio.post(
        'banners',
        data: bannerData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateBanner(String id, Map<String, dynamic> bannerData, String token) async {
    try {
      final response = await _dio.put(
        'banners/$id',
        data: bannerData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteBanner(String id, String token) async {
    try {
      final response = await _dio.delete(
        'banners/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadImage(File imageFile, String token) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "images": [await MultipartFile.fromFile(imageFile.path, filename: fileName)],
      });

      final response = await _dio.post(
        'products/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['images'][0];
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading banner image: $e');
      return null;
    }
  }
}
