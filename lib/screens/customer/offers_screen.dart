import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/offer_provider.dart';
import '../../widgets/offers/offer_banner.dart';
import 'offer_details_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Exclusive Offers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, provider, child) {
          final activeOffers = provider.activeOffers;

          if (activeOffers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeOffers.length,
            itemBuilder: (context, index) {
              final offer = activeOffers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  height: 220,
                  child: OfferBanner(
                    offer: offer,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OfferDetailsScreen(offer: offer)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          const Text(
            'No Active Offers',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check back later for more updates.',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
