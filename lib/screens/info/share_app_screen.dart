import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

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
            const SizedBox(height: 48),
            CustomButton(
              text: 'SHARE NOW',
              onPressed: () {
                // In real app use: Share.share('Download Raymaans Tailors app for the perfect fit!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Share Dialog...')),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
