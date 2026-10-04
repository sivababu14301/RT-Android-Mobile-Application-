import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/payment_model.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withAlpha(13) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(25),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? Colors.black : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: TextStyle(
                      color: isSelected ? AppColors.gold : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.gold,
                size: 24,
              )
            else
              const Icon(
                Icons.circle_outlined,
                color: Colors.white10,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
