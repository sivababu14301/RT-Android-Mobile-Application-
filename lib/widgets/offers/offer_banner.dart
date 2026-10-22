import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/offer_model.dart';
import '../../config/app_colors.dart';
import 'offer_countdown.dart';

class OfferBanner extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const OfferBanner({super.key, required this.offer, required this.onTap});

  Widget _buildOfferImageWidget(String url) {
    final clean = url.trim();
    if (clean.isEmpty) {
      return Container(
        color: Colors.grey[900],
        width: double.infinity,
        height: double.infinity,
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
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[900],
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
            ),
          ),
        );
      } catch (e) {
        return Container(
          color: Colors.grey[900],
          width: double.infinity,
          height: double.infinity,
          child: const Center(
            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
          ),
        );
      }
    }

    return Image.network(
      clean,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[900],
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Hero Image
              Hero(
                tag: 'offer_${offer.id}',
                child: _buildOfferImageWidget(offer.fullImageUrl),
              ),
              
              // Dark Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(230),
                      Colors.black.withAlpha(51),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        offer.discount,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.offerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OfferCountdown(endDate: offer.endDateTime),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gold),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SHOP NOW',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
