import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final token = context.read<UserProvider>().user?.token;
    if (token != null) {
      await context.read<WishlistProvider>().fetchWishlist(token);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wishlist ❤️',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (_isLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const OrderCardSkeleton(),
            );
          }

          if (wishlist.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_outline_rounded,
                        size: 100,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Your Wishlist is Empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Looks like you haven't added any favorite products yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          elevation: 8,
                          shadowColor: AppColors.gold.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE SHOPPING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double horizontalPadding = 32.0; // 16 left + 16 right
              final double crossAxisSpacing = 16.0;
              final double availableWidth = screenWidth - horizontalPadding - crossAxisSpacing;
              final double cardWidth = availableWidth / 2;

              final double detailsHeight = 68.0;
              final double imageHeight = cardWidth * 1.25;
              final double totalCardHeight = imageHeight + detailsHeight;
              final double dynamicAspectRatio = (cardWidth / totalCardHeight).clamp(0.55, 0.75);

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: dynamicAspectRatio,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: 16,
                ),
                itemCount: wishlist.items.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: wishlist.items[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
