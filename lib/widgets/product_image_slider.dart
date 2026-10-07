import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  static const String fallbackImageUrl =
      'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=1000&auto=format&fit=crop';

  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _openFullScreenViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: widget.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full black background container displaying complete original image
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.isEmpty ? 1 : widget.images.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.images.isNotEmpty ? widget.images[index] : ProductImageSlider.fallbackImageUrl;
              return GestureDetector(
                onTap: () => _openFullScreenViewer(index),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 24, left: 8, right: 8),
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          ProductImageSlider.fallbackImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 60),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Page Indicators (floating at the bottom of the image area)
        if (widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 12.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key 
                      ? AppColors.gold 
                      : AppColors.gold.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({required this.images, required this.initialIndex});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (idx) => setState(() => _currentIndex = idx),
        itemCount: widget.images.isEmpty ? 1 : widget.images.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.images.isNotEmpty ? widget.images[index] : ProductImageSlider.fallbackImageUrl;
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Image.network(ProductImageSlider.fallbackImageUrl, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
