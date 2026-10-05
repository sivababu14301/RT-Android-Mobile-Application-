import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiConfig {
  static const String wifiIp = '10.69.215.137';
  static const String emulatorIp = '10.0.2.2';
  static const String port = '5000';

  static String get baseUrl {
      return 'https://rt-android-mobile-application.onrender.com/api/';
  }

  static String get baseServerUrl {
    return 'https://rt-android-mobile-application.onrender.com';
  }

  static List<String> get candidateHosts {
    return [
      'rt-android-mobile-application.onrender.com',
    ];
  }

  static Interceptor get retryInterceptor => InterceptorsWrapper(
        onError: (DioException err, handler) async {
          if (err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.connectionError ||
              err.type == DioExceptionType.receiveTimeout ||
              err.response?.statusCode == 404) {
            final opts = err.requestOptions;
            final currentBase = opts.baseUrl;

            for (final host in candidateHosts) {
              if (!currentBase.contains(host)) {
                try {
                  final newBase = currentBase.replaceAll(
                    RegExp(r'https?://[^/]+'),
                    'https://$host',
                  );
                  debugPrint('🔄 Retrying request with candidate base URL: $newBase${opts.path}');

                  final client = Dio(BaseOptions(
                    connectTimeout: const Duration(seconds: 5),
                    receiveTimeout: const Duration(seconds: 5),
                    validateStatus: (status) => true,
                  ));

                  final newOptions = opts.copyWith(baseUrl: newBase);
                  final response = await client.fetch(newOptions);

                  if (response.statusCode != null && response.statusCode! < 400) {
                    return handler.resolve(response);
                  }
                } catch (retryErr) {
                  debugPrint('Candidate host $host failed: $retryErr');
                  continue;
                }
              }
            }
          }
          return handler.next(err);
        },
      );
}
