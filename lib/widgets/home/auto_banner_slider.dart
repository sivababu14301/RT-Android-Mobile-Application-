import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  BannerItem({required this.title, required this.subtitle, required this.imageUrl});
}

class AutoBannerSlider extends StatefulWidget {
  const AutoBannerSlider({super.key});

  @override
  State<AutoBannerSlider> createState() => _AutoBannerSliderState();
}

class _AutoBannerSliderState extends State<AutoBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<BannerItem> _banners = [
    BannerItem(
      title: 'Premium Formal Shirts',
      subtitle: 'Tailored to perfection for a sharp look.',
      imageUrl: 'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?q=80&w=1000&auto=format&fit=crop',
    ),
    BannerItem(
      title: 'Premium T-Shirts',
      subtitle: 'Comfort meets premium craftsmanship.',
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop',
    ),
    BannerItem(
      title: 'Premium Formal Pants',
      subtitle: 'Custom fit for every occasion.',
      imageUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?q=80&w=1000&auto=format&fit=crop',
    ),
    BannerItem(
      title: 'Traditional Wedding Collection',
      subtitle: 'Royal attire for your special day.',
      imageUrl: 'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=1000&auto=format&fit=crop',
    ),
    BannerItem(
      title: 'School & College Uniforms',
      subtitle: 'Premium quality for daily durability.',
      imageUrl: 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=1000&auto=format&fit=crop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return _buildBannerCard(_banners[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _banners.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == entry.key ? 20.0 : 8.0,
              height: 4.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColors.gold.withOpacity(_currentPage == entry.key ? 1.0 : 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BannerItem banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(banner.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              banner.title,
              style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              banner.subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
