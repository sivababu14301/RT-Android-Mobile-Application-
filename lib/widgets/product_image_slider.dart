import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  static Widget buildSingleImage(String url, {BoxFit fit = BoxFit.contain}) {
    final clean = url.trim();
    if (clean.isEmpty) {
      return const Center(
        child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 60),
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
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 60),
          ),
        );
      } catch (e) {
        return const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 60),
        );
      }
    }

    return Image.network(
      clean,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      gaplessPlayback: true,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 60),
      ),
    );
  }

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late PageController _pageController;
  late ValueNotifier<int> _currentIndexNotifier;
  bool _isPrecached = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndexNotifier = ValueNotifier<int>(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      _precacheSliderImages();
    }
  }

  void _precacheSliderImages() {
    for (String url in widget.images) {
      final clean = url.trim();
      if (clean.isEmpty) continue;

      if (clean.startsWith('data:image/')) {
        try {
          final base64Str = clean.split(',').last;
          final bytes = base64Decode(base64Str);
          precacheImage(MemoryImage(bytes), context).catchError((e) {
            debugPrint("⚠️ Precache memory image error: $e");
          });
        } catch (_) {}
      } else if (clean.startsWith('http')) {
        precacheImage(NetworkImage(clean), context).catchError((e) {
          debugPrint("⚠️ Precache network image error: $e");
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

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
    final List<String> displayImages =
        widget.images.where((img) => img.trim().isNotEmpty).toList();

    if (displayImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 80),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              _currentIndexNotifier.value = index;
            },
            itemCount: displayImages.length,
            itemBuilder: (context, index) {
              final imageUrl = displayImages[index];
              return GestureDetector(
                onTap: () => _openFullScreenViewer(index),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 24, left: 8, right: 8),
                  child: Center(
                    child: ProductImageSlider.buildSingleImage(imageUrl, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
        ),
        
        if (displayImages.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndexNotifier,
              builder: (context, currentIndex, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: displayImages.asMap().entries.map((entry) {
                    final bool isSelected = currentIndex == entry.key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 12.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected 
                          ? AppColors.gold 
                          : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                );
              },
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
  late ValueNotifier<int> _currentIndexNotifier;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _currentIndexNotifier = ValueNotifier<int>(widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> displayImages =
        widget.images.where((img) => img.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: ValueListenableBuilder<int>(
          valueListenable: _currentIndexNotifier,
          builder: (context, currentIndex, child) {
            return Text(
              displayImages.isNotEmpty ? '${currentIndex + 1} / ${displayImages.length}' : '0 / 0',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            );
          },
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (idx) => _currentIndexNotifier.value = idx,
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          final imageUrl = displayImages[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: ProductImageSlider.buildSingleImage(imageUrl, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
