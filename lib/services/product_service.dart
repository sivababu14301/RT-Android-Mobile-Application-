import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../models/product_model.dart';

class ProductService {
  static String get _baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;

  ProductService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  String _handleError(Response response) {
    debugPrint("❌ SERVER ERROR STATUS: ${response.statusCode}");
    debugPrint("❌ DATA CONTENT: ${response.data}");
    
    if (response.data is Map && response.data['message'] != null) {
      return response.data['message'].toString();
    }
    return 'Server Error: ${response.statusCode}';
  }

  Future<List<Product>> getProducts({String? category, String? search, int? limit}) async {
    try {
      final response = await _dio.get('products/', queryParameters: {
        if (category != null && category != 'All') 'category': category,
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit,
      });

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        final List productsJson = response.data['products'] ?? [];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<String>> uploadImages(List<File> imageFiles, String token) async {
    try {
      const uploadUrl = 'products/upload';
      debugPrint("🚀 UPLOADING IMAGES TO: $_baseUrl$uploadUrl");

      final formData = FormData();
      for (var file in imageFiles) {
        if (!file.existsSync()) {
          debugPrint("⚠️ Skipping missing image file: ${file.path}");
          continue;
        }
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            "images",
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      if (formData.files.isEmpty) {
        debugPrint("⚠️ No valid image files to upload.");
        return [];
      }

      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      debugPrint("📸 UPLOAD RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📸 UPLOAD RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        final List<String> urls = List<String>.from(response.data['images'] ?? []);
        debugPrint("✅ RECEIVED UPLOADED IMAGE URLS: $urls");
        return urls;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint("❌ UPLOAD EXCEPTION: $e");
      if (e is DioException) {
        if (e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
          throw 'Image upload timed out. Please try again with smaller images or check your network.';
        } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
          throw 'Network error during image upload. Please check your internet connection.';
        } else if (e.response != null) {
          throw _handleError(e.response!);
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData, String token) async {
    try {
      const path = 'products/';
      final response = await _dio.post(
        path,
        data: productData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      
      if (response.statusCode == 201 && response.data is Map) {
        return response.data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw _handleError(e.response!);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData, String token) async {
    try {
      final path = 'products/$id';
      final response = await _dio.put(
        path,
        data: productData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      
      if (response.statusCode == 200 && response.data is Map) {
        return response.data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw _handleError(e.response!);
      }
      rethrow;
    }
  }

  Future<bool> deleteProduct(String id, String token) async {
    try {
      final path = 'products/$id';
      final response = await _dio.delete(
        path,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Review methods
  Future<Map<String, dynamic>> getProductReviews(String productId) async {
    try {
      final response = await _dio.get('products/$productId/reviews');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {'success': false, 'reviews': []};
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return {'success': false, 'reviews': []};
    }
  }

  Future<Map<String, dynamic>> submitReview(
    String productId, 
    int rating, 
    String comment, 
    List<String> images, 
    String token
  ) async {
    try {
      final response = await _dio.post(
        'products/$productId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
          'images': images,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map) {
        return response.data;
      }
      return {'success': false, 'message': 'Failed to submit review'};
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false, 
          'message': e.response?.data['message'] ?? 'Failed to submit review'
        };
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}
