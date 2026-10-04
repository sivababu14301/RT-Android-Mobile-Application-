import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 150,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/rt_logo.png',
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.shield_rounded,
            size: size,
            color: AppColors.gold,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          const Text(
            'RAYMAANS',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const Text(
            'TAILORS',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              letterSpacing: 8,
            ),
          ),
        ],
      ],
    );
  }
}
