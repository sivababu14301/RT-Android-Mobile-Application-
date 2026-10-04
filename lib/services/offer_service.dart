import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../models/offer_model.dart';

class OfferService {
  static String get _baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;

  OfferService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<List<OfferModel>> getOffers() async {
    try {
      final response = await _dio.get('offers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List offersJson = response.data['offers'] ?? [];
        return offersJson.map((json) => OfferModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addOffer(Map<String, dynamic> offerData, String token) async {
    try {
      final response = await _dio.post(
        'offers',
        data: offerData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateOffer(String id, Map<String, dynamic> offerData, String token) async {
    try {
      final response = await _dio.put(
        'offers/$id',
        data: offerData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteOffer(String id, String token) async {
    try {
      final response = await _dio.delete(
        'offers/$id',
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
      debugPrint('Error uploading offer image: $e');
      return null;
    }
  }
}
