import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/measurement_model.dart';

class MeasurementService {
  static String get _baseUrl => ApiConfig.baseUrl;

  final Dio _dio;

  MeasurementService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true,
        )) {
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<Response> createMeasurement(MeasurementModel measurement) async {
    const path = 'measurements';
    final url = '$_baseUrl$path';
    debugPrint("MEASUREMENT URL: $url");
    return await _dio.post(path, data: measurement.toJson());
  }

  Future<Response> getMyMeasurements() async {
    return await _dio.get('measurements');
  }

  Future<Response> getMeasurementById(String id) async {
    return await _dio.get('measurements/$id');
  }

  Future<Response> updateMeasurement(String id, MeasurementModel measurement) async {
    return await _dio.put('measurements/$id', data: measurement.toJson());
  }

  Future<Response> deleteMeasurement(String id) async {
    return await _dio.delete('measurements/$id');
  }
}
