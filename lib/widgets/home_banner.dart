import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/banner_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_nav_provider.dart';
import '../models/banner_model.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<BannerModel> _defaultBanners = [
    BannerModel(
      id: 'default_1',
      title: 'PREMIUM TAILORING',
      image: 'https://images.unsplash.com/photo-1594932224828-b4b05a832971?q=80&w=1000&auto=format&fit=crop',
      link: 'Suits',
      isActive: true,
    ),
    BannerModel(
      id: 'default_2',
      title: 'BESPOKE SUITS',
      image: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1000&auto=format&fit=crop',
      link: 'Suits',
      isActive: true,
    ),
    BannerModel(
      id: 'default_3',
      title: 'CUSTOM SHIRTS',
      image: 'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=1000&auto=format&fit=crop',
      link: 'Shirts',
      isActive: true,
    ),
    BannerModel(
      id: 'default_4',
      title: 'PERFECT FIT PANTS',
      image: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=1000&auto=format&fit=crop',
      link: 'Pants',
      isActive: true,
    ),
    BannerModel(
      id: 'default_5',
      title: 'EXCLUSIVE COLLECTION',
      image: 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=1000&auto=format&fit=crop',
      link: 'All',
      isActive: true,
    ),
  ];

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
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        final provider = context.read<BannerProvider>();
        final banners = provider.activeBanners.isNotEmpty
            ? provider.activeBanners
            : _defaultBanners;

        if (banners.isNotEmpty) {
          if (_currentPage < banners.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }

          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuint,
          );
        }
      }
    });
  }

  void _onExploreNow(BuildContext context, BannerModel banner) {
    String targetCategory = banner.category.isNotEmpty ? banner.category : banner.link.trim();
    String targetCategoryId = banner.categoryId;

    if (targetCategory.isEmpty || targetCategory == 'All') {
      final titleLower = banner.title.toLowerCase();
      if (titleLower.contains('tshirt') || titleLower.contains('t-shirt')) {
        targetCategory = 'T-Shirts';
      } else if (titleLower.contains('shirt')) {
        targetCategory = 'Shirts';
      } else if (titleLower.contains('pant') || titleLower.contains('trouser') || titleLower.contains('paint')) {
        targetCategory = 'Pants';
      } else if (titleLower.contains('suit')) {
        targetCategory = 'Suits';
      } else if (titleLower.contains('wedding')) {
        targetCategory = 'Wedding Collection';
      } else if (titleLower.contains('uniform')) {
        targetCategory = 'Uniforms';
      } else {
        targetCategory = 'All';
      }
    }

    final productProvider = context.read<ProductProvider>();
    if (targetCategory == 'All') {
      productProvider.resetToAll();
    } else {
      productProvider.applyCategoryOfferFilter(targetCategory, categoryId: targetCategoryId);
    }

    // Switch to Products tab in bottom navigation bar
    context.read<CustomerNavProvider>().setIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        final List<BannerModel> banners = provider.activeBanners.isNotEmpty
            ? provider.activeBanners
            : _defaultBanners;

        if (provider.isLoading && provider.activeBanners.isEmpty) {
          return Container(
            height: 190,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 190,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return _buildBannerItem(banners[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == entry.key ? 20.0 : 8.0,
                  height: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.gold.withValues(alpha: _currentPage == entry.key ? 1.0 : 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return GestureDetector(
      onTap: () => _onExploreNow(context, banner),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                banner.fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black26,
                    child: const Center(child: Icon(Icons.broken_image, color: AppColors.gold)),
                  );
                },
              ),
              // Black Overlay Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.title.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => _onExploreNow(context, banner),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          elevation: 5,
                          shadowColor: AppColors.gold.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                        ),
                        child: const Text(
                          'EXPLORE NOW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
