import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/share_app_service.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';

class ShareAppScreen extends StatefulWidget {
  const ShareAppScreen({super.key});

  @override
  State<ShareAppScreen> createState() => _ShareAppScreenState();
}

class _ShareAppScreenState extends State<ShareAppScreen> {
  bool _isSharing = false;
  double _downloadProgress = 0.0;
  String _statusText = '';

  Future<void> _handleShareNow() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
      _downloadProgress = 0.0;
      _statusText = 'Preparing installed App APK...';
    });

    try {
      final File? apkFile = await ShareAppService.prepareInstalledApk(
        onProgress: (pct) {
          if (mounted) {
            setState(() {
              _downloadProgress = pct;
              _statusText = 'Preparing App APK (${(pct * 100).toInt()}%)...';
            });
          }
        },
      );

      if (apkFile != null && await apkFile.exists()) {
        if (mounted) {
          setState(() {
            _statusText = 'Opening Android Share Menu...';
          });
        }

        await ShareAppService.shareApk(apkFile);

        if (mounted) {
          setState(() {
            _isSharing = false;
            _statusText = '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isSharing = false;
            _statusText = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not access the installed app APK on this device.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSharing = false;
          _statusText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share APK: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Share App',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(size: 150, showText: false),
            const SizedBox(height: 24),
            const Text(
              'RT - Raymaans Tailors',
              style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Love your perfect fit? Share the Raymaans Tailors experience with your friends and family!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 36),

            if (_isSharing) ...[
              if (_downloadProgress > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.white10,
                    color: AppColors.gold,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
            ],

            _isSharing
                ? const CircularProgressIndicator(color: AppColors.gold)
                : CustomButton(
                    text: 'SHARE NOW',
                    onPressed: _handleShareNow,
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
