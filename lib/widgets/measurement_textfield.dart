import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class MeasurementTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback? onInfoTap;

  const MeasurementTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onInfoTap != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onInfoTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: AppColors.gold.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (onInfoTap != null)
                GestureDetector(
                  onTap: onInfoTap,
                  child: const Text(
                    'How to measure?',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixText: label != 'Height' ? 'inch' : null,
                suffixStyle: const TextStyle(color: AppColors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
