import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class TodaysOfferData {
  final String offerName;
  final String description;
  final String discount;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  TodaysOfferData({
    required this.offerName,
    required this.description,
    required this.discount,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  bool get isActive {
    final now = DateTime.now();
    return status == 'Active' && 
           now.isAfter(startDate) && 
           now.isBefore(endDate.add(const Duration(days: 1)));
  }
}

class TodaysOffer extends StatelessWidget {
  const TodaysOffer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data - In future, this will come from a Provider/Backend
    final offer = TodaysOfferData(
      offerName: 'Premium Formal Pants',
      discount: '20% OFF',
      description: 'Premium Quality Formal Wear tailored for perfection.',
      imageUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?q=80&w=1000&auto=format&fit=crop',
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 15),
      status: 'Active',
    );

    // Current Date check logic for future backend integration
    // For demo purposes, I'll bypass the date check since it's 2026, 
    // but the logic is implemented in the model above.
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Offer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Banner Image
                  Image.network(
                    offer.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  
                  // Black Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            offer.discount,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          offer.offerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 200,
                          child: Text(
                            offer.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            elevation: 5,
                            shadowColor: AppColors.gold.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                          ),
                          child: const Text(
                            'Shop Now',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
