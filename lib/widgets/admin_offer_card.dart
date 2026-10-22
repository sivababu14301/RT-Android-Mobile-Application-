import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offer_model.dart';
import '../config/app_colors.dart';

class AdminOfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const AdminOfferCard({
    super.key,
    required this.offer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  Widget _buildOfferImageWidget(String url) {
    final clean = url.trim();
    if (clean.isEmpty) {
      return Container(
        height: 140,
        color: Colors.white10,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
        ),
      );
    }

    if (clean.startsWith('data:image/')) {
      try {
        final base64Str = clean.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 140,
            color: Colors.white10,
            child: const Center(
              child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
            ),
          ),
        );
      } catch (e) {
        return Container(
          height: 140,
          color: Colors.white10,
          child: const Center(
            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
          ),
        );
      }
    }

    return Image.network(
      clean,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 140,
        color: Colors.white10,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = offer.calculatedStatus;
    final dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

    Color statusColor;
    String statusText;
    switch (status) {
      case OfferStatus.active:
        statusColor = Colors.green;
        statusText = 'ACTIVE';
        break;
      case OfferStatus.upcoming:
        statusColor = Colors.amber;
        statusText = 'UPCOMING';
        break;
      case OfferStatus.expired:
        statusColor = Colors.red;
        statusText = 'EXPIRED';
        break;
      case OfferStatus.inactive:
        statusColor = Colors.grey;
        statusText = 'INACTIVE';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offer Image with Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildOfferImageWidget(offer.fullImageUrl),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(230),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.offerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.discount,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: offer.isEnabled,
                      onChanged: onToggle,
                      activeThumbColor: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDateTimeInfo(Icons.play_circle_outline, 'Starts:', dateTimeFormat.format(offer.startDateTime)),
                const SizedBox(height: 6),
                _buildDateTimeInfo(Icons.stop_circle_outlined, 'Ends:  ', dateTimeFormat.format(offer.endDateTime)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 14),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 11),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
