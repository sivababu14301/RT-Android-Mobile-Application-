import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;
  final Widget? extraContent;
  final Widget? leadingIcon;
  final String? badgeText;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
    this.extraContent,
    this.leadingIcon,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF221F18) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white10,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
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
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Optional leading custom icon
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: 14),
                ],

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isRecommended || badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isRecommended
                                    ? AppColors.gold.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isRecommended ? AppColors.gold : Colors.green,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                badgeText ?? '⭐ Recommended',
                                style: TextStyle(
                                  color: isRecommended ? AppColors.gold : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
              const SizedBox(height: 14),
              extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}
