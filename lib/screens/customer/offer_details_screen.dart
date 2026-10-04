import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/offer_model.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

class OfferDetailsScreen extends StatelessWidget {
  final OfferModel offer;

  const OfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'offer_${offer.id}',
                child: Image.network(
                  offer.fullImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      '${offer.discount} DISCOUNT',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    offer.offerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Offer Validity',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildValidityRow('Valid From', dateFormat.format(offer.startDateTime)),
                  _buildValidityRow('Valid Until', dateFormat.format(offer.endDateTime)),
                  const SizedBox(height: 32),
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTermItem('Offer is applicable on all selected items.'),
                  _buildTermItem('Cannot be combined with other promo codes.'),
                  _buildTermItem('Valid for online and in-store tailoring services.'),
                  _buildTermItem('Raymaans Tailors reserves the right to modify the offer.'),
                  
                  const SizedBox(height: 48),
                  CustomButton(
                    text: 'SHOP NOW',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.gold, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 14))),
        ],
      ),
    );
  }
}
