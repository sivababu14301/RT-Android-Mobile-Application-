import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ShareAppService {
  // Hosted release APK URL fallback for production
  static const String _hostedApkUrl =
      'https://github.com/sivababu14301/RT-Android-Mobile-Application-/raw/main/build/app/outputs/flutter-apk/app-release.apk';

  /// Locates existing local APK or downloads the release APK file
  static Future<File?> prepareApkFile({void Function(double progress)? onProgress}) async {
    try {
      Directory? tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (_) {
        tempDir = await getApplicationDocumentsDirectory();
      }

      final String targetPath = '${tempDir.path}/rt_raymaans_tailors.apk';
      final File targetFile = File(targetPath);

      // Check if APK already exists locally and is valid (> 5MB)
      if (await targetFile.exists() && (await targetFile.length()) > 5000000) {
        debugPrint("✅ Found cached local APK file: ${targetFile.path} (${await targetFile.length()} bytes)");
        return targetFile;
      }

      // Check external downloads directory
      if (Platform.isAndroid) {
        try {
          final Directory? extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final File extFile = File('${extDir.path}/app-release.apk');
            if (await extFile.exists() && (await extFile.length()) > 5000000) {
              debugPrint("✅ Found external release APK: ${extFile.path}");
              return extFile;
            }
          }
        } catch (_) {}
      }

      // Download release APK from hosted URL
      debugPrint("🚀 Downloading release APK from $_hostedApkUrl...");
      final dio = Dio();
      await dio.download(
        _hostedApkUrl,
        targetPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            final pct = (received / total).clamp(0.0, 1.0);
            onProgress(pct);
          }
        },
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      if (await targetFile.exists() && (await targetFile.length()) > 1000000) {
        debugPrint("✅ APK download complete: ${targetFile.path}");
        return targetFile;
      }

      return null;
    } catch (e) {
      debugPrint("❌ APK Preparation Error: $e");
      return null;
    }
  }

  /// Shares the APK file using native Android Share Sheet
  static Future<void> shareApk(File apkFile) async {
    final Uint8List apkBytes = await apkFile.readAsBytes();
    await Printing.sharePdf(
      bytes: apkBytes,
      filename: 'RT_Raymaans_Tailors.apk',
    );
  }
}
