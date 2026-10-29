package com.example.rt_raymaans_tailors

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.rt_raymaans_tailors/apk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApkPath") {
                try {
                    val apkPath = applicationInfo.sourceDir
                    val file = File(apkPath)
                    if (file.exists() && file.length() > 0) {
                        result.success(apkPath)
                    } else {
                        result.error("NOT_FOUND", "Installed APK file not found at $apkPath", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
