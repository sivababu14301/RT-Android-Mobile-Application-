import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/wishlist_card.dart';
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
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => const OrderCardSkeleton(), // Reuse OrderCardSkeleton for wishlist list items
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
                        color: AppColors.gold.withOpacity(0.1),
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
                          shadowColor: AppColors.gold.withOpacity(0.4),
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

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              return WishlistCard(product: wishlist.items[index]);
            },
          );
        },
      ),
    );
  }
}
