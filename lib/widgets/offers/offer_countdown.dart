import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class OfferCountdown extends StatelessWidget {
  final DateTime endDate;

  const OfferCountdown({super.key, required this.endDate});

  @override
  Widget build(BuildContext context) {
    // In a real app, use a Timer to update every second.
    // For UI demo, we show dummy values.
    final diff = endDate.difference(DateTime.now());
    
    if (diff.isNegative) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, color: AppColors.gold, size: 14),
        const SizedBox(width: 6),
        const Text(
          'Ends In: ',
          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        _buildTimeBox('${diff.inDays}', 'D'),
        _buildTimeBox('${diff.inHours % 24}', 'H'),
        _buildTimeBox('${diff.inMinutes % 60}', 'M'),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.gold, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
