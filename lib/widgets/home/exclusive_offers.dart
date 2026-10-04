import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/offer_model.dart';
import '../../providers/offer_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_nav_provider.dart';

class ExclusiveOffers extends StatefulWidget {
  const ExclusiveOffers({super.key});

  @override
  State<ExclusiveOffers> createState() => _ExclusiveOffersState();
}

class _ExclusiveOffersState extends State<ExclusiveOffers> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        final activeOffers = context.read<OfferProvider>().activeOffers;
        if (activeOffers.isEmpty) return;

        if (_currentPage < activeOffers.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  String _getCategoryName(OfferModel offer) {
    String category = offer.link.trim();
    if (category.startsWith('product:')) {
      final pid = category.replaceFirst('product:', '');
      final productProvider = context.read<ProductProvider>();
      final prodList = productProvider.products.where((p) => p.id == pid).toList();
      if (prodList.isNotEmpty) {
        return prodList.first.category;
      }
      return 'Shirts';
    }

    // Direct Category match from Admin selection
    if (category.isNotEmpty && category.toLowerCase() != 'all') {
      return category;
    }

    // Fallback Keyword detection from Offer Name or Description
    final nameLower = '${offer.offerName} ${offer.description}'.toLowerCase();
    
    if (nameLower.contains('tshirt') || nameLower.contains('t-shirt')) {
      return 'T-Shirts';
    }
    if (nameLower.contains('shirt')) {
      return 'Shirts';
    }
    if (nameLower.contains('pant') || nameLower.contains('trouser') || nameLower.contains('paint')) {
      return 'Pants';
    }
    if (nameLower.contains('suit')) {
      return 'Suits';
    }
    if (nameLower.contains('wedding')) {
      return 'Wedding Collection';
    }
    if (nameLower.contains('unfome') || nameLower.contains('uniform') || nameLower.contains('school') || nameLower.contains('college')) {
      return 'Uniforms';
    }

    return 'Shirts';
  }

  String _getCategoryEmoji(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('uniform') || lower.contains('unfome')) return '🎓';
    if (lower.contains('t-shirt') || lower.contains('tshirt')) return '👕';
    if (lower.contains('shirt')) return '👔';
    if (lower.contains('pant') || lower.contains('trouser') || lower.contains('paint')) return '👖';
    if (lower.contains('suit')) return '🤵';
    if (lower.contains('wedding')) return '👑';
    return '🏷️';
  }

  void _onShopNow(BuildContext context, OfferModel offer) {
    final productProvider = context.read<ProductProvider>();

    if (offer.targetType == 'product' || offer.productId.isNotEmpty || offer.productIds.isNotEmpty || offer.link.startsWith('product:')) {
      List<String> targetPids = offer.productIds.isNotEmpty
          ? offer.productIds
          : (offer.productId.isNotEmpty ? [offer.productId] : []);

      if (targetPids.isEmpty && offer.link.startsWith('product:')) {
        final pidStr = offer.link.replaceFirst('product:', '');
        targetPids = pidStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }

      if (targetPids.isNotEmpty) {
        productProvider.applySpecificProductOfferFilter(targetPids, offerId: offer.id);
        context.read<CustomerNavProvider>().setIndex(2);
        return;
      }
    }

    final categoryName = _getCategoryName(offer);
    productProvider.applyCategoryOfferFilter(categoryName, offerId: offer.id);

    // Switch to Products tab in bottom navigation bar
    context.read<CustomerNavProvider>().setIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        final activeOffers = provider.activeOffers;
        if (activeOffers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Exclusive Offers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 175,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: activeOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferBanner(activeOffers[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: activeOffers.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == entry.key ? 18.0 : 6.0,
                  height: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.gold.withAlpha(_currentPage == entry.key ? 255 : 51),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfferBanner(OfferModel offer) {
    final categoryName = _getCategoryName(offer);
    final emoji = _getCategoryEmoji(categoryName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () => _onShopNow(context, offer),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(offer.fullImageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withAlpha(225),
                  Colors.black.withAlpha(115),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Discount Tag
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                  offer.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _onShopNow(context, offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
