import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class OfferItem {
  final String title;
  final String discount;
  final String description;
  final String validUntil;
  final String imageUrl;

  OfferItem({
    required this.title,
    required this.discount,
    required this.description,
    required this.validUntil,
    required this.imageUrl,
  });
}

class HomeOffers extends StatelessWidget {
  const HomeOffers({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OfferItem> offers = [
      OfferItem(
        title: 'Formal Shirts',
        discount: 'Flat 20% OFF',
        description: 'Premium cotton shirts at unbeatable prices.',
        validUntil: '31 Aug 2026',
        imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=1000&auto=format&fit=crop',
      ),
      OfferItem(
        title: 'T-Shirts',
        discount: 'Buy 2 Get 1 Free',
        description: 'Upgrade your basics with our premium t-shirts.',
        validUntil: '15 Aug 2026',
        imageUrl: 'https://static.vecteezy.com/system/resources/thumbnails/038/587/305/small/ai-generated-two-black-t-shirts-hanging-on-a-hanger-white-background-clothing-store-advertisement-photo.jpg',
      ),
      OfferItem(
        title: 'Wedding Collection',
        discount: '15% OFF',
        description: 'Make your special day royal with custom fits.',
        validUntil: '20 Sep 2026',
        imageUrl: 'https://www.hindustancottonclub.com/cdn/shop/files/IMG-2606.jpg?v=1704868570&width=1445',
      ),
      OfferItem(
        title: 'School Uniforms',
        discount: '10% OFF',
        description: 'Durable and well-fitted school uniforms.',
        validUntil: '10 Aug 2026',
        imageUrl: 'https://content.jdmagicbox.com/comp/dharmapuri/g3/9999px424.x424.140608181445.f5g3/catalogue/newton-s-apple-school-pennagaram-dharmapuri-schools-pwp9svl9gp.jpg',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Special Offers',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              return _buildOfferCard(offers[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(OfferItem offer) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          offer.discount,
                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        offer.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'Valid until: ${offer.validUntil}',
                        style: const TextStyle(color: AppColors.gold, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold.withOpacity(0.1),
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.gold, width: 0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Shop Now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                  child: Image.network(
                    offer.imageUrl,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
