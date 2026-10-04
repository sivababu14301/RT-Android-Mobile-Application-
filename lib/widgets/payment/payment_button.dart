import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class PaymentButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const PaymentButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isSecondary
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                elevation: 8,
                shadowColor: AppColors.gold.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
            ),
    );
  }
}
