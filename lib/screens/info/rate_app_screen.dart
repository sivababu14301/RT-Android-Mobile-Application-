import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;

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
          'Rate App',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, size: 100, color: AppColors.gold),
            const SizedBox(height: 32),
            const Text(
              'Enjoying the App?',
              style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your feedback helps us provide you with the best tailored experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.gold,
                    size: 45,
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'RATE NOW',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your rating!')),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Write a Review',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
