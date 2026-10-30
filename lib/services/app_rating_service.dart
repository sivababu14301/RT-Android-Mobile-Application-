import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AppRatingService {
  static String get _baseUrl => ApiConfig.baseUrl;
  late final Dio _dio;

  AppRatingService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true,
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  /// Submits star rating & feedback to backend API
  Future<Map<String, dynamic>> submitRating({
    required int rating,
    required String feedback,
    String? name,
    String? email,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        'app-ratings',
        data: {
          'rating': rating,
          'feedback': feedback,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201 && response.data is Map && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Thank you for your rating! Your feedback has been sent to raymaanstailors@gmail.com.',
        };
      } else {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Server returned error status (${response.statusCode})';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      debugPrint("❌ Submit App Rating Error: $e");
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Admin endpoint: Fetches submitted app ratings and feedback
  Future<Map<String, dynamic>> getAppRatings(String adminToken) async {
    try {
      final response = await _dio.get(
        'app-ratings',
        options: Options(
          headers: {'Authorization': 'Bearer $adminToken'},
        ),
      );

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        return {
          'success': true,
          'ratings': response.data['ratings'] ?? [],
          'count': response.data['count'] ?? 0,
          'avgRating': response.data['avgRating'] ?? 0.0,
        };
      } else {
        return {'success': false, 'ratings': [], 'count': 0, 'avgRating': 0.0};
      }
    } catch (e) {
      debugPrint("❌ Get App Ratings Error: $e");
      return {'success': false, 'ratings': [], 'count': 0, 'avgRating': 0.0};
    }
  }
}
