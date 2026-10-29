import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppService {
  static const MethodChannel _channel = MethodChannel('com.example.rt_raymaans_tailors/apk');

  /// Safely extracts the currently installed application APK from Android system storage without internet
  static Future<File?> prepareInstalledApk({void Function(double progress)? onProgress}) async {
    try {
      Directory? tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (_) {
        tempDir = await getApplicationDocumentsDirectory();
      }

      final String targetPath = '${tempDir.path}/RT_Raymaans_Tailors.apk';
      final File targetFile = File(targetPath);

      if (onProgress != null) onProgress(0.2);

      // 1. Try MethodChannel to retrieve installed APK sourceDir from Android PackageManager
      if (Platform.isAndroid) {
        try {
          final String? sourceApkPath = await _channel.invokeMethod<String>('getInstalledApkPath');
          if (sourceApkPath != null && sourceApkPath.isNotEmpty) {
            final File sourceFile = File(sourceApkPath);
            if (await sourceFile.exists() && (await sourceFile.length()) > 1000000) {
              debugPrint("✅ Found installed base.apk at: $sourceApkPath (${await sourceFile.length()} bytes)");
              
              if (onProgress != null) onProgress(0.5);

              // Copy base.apk to temp location for sharing permissions
              await sourceFile.copy(targetPath);

              if (await targetFile.exists() && (await targetFile.length()) > 1000000) {
                if (onProgress != null) onProgress(1.0);
                debugPrint("✅ Prepared installed APK file for sharing: ${targetFile.path}");
                return targetFile;
              }
            }
          }
        } catch (channelErr) {
          debugPrint("⚠️ MethodChannel APK lookup error: $channelErr");
        }
      }

      // 2. Check if targetFile already exists in temp cache
      if (await targetFile.exists() && (await targetFile.length()) > 1000000) {
        if (onProgress != null) onProgress(1.0);
        return targetFile;
      }

      return null;
    } catch (e) {
      debugPrint("❌ ShareAppService Error: $e");
      return null;
    }
  }

  /// Shares the APK file using share_plus with application/vnd.android.package-archive MIME type
  static Future<void> shareApk(File apkFile) async {
    try {
      final xFile = XFile(
        apkFile.path,
        mimeType: 'application/vnd.android.package-archive',
        name: 'RT_Raymaans_Tailors.apk',
      );

      await Share.shareXFiles(
        [xFile],
        text: 'Download and install RT - Raymaans Tailors App!',
        subject: 'RT - Raymaans Tailors App APK',
      );
    } catch (e) {
      debugPrint("❌ share_plus Error: $e");
      rethrow;
    }
  }
}
