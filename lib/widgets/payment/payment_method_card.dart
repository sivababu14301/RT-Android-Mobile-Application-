import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;
  final Widget? extraContent;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
    this.extraContent,
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
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '⭐ Recommended',
                                style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (extraContent != null && isSelected) ...[
              const SizedBox(height: 16),
              extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}
