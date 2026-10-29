import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import '../providers/user_provider.dart';
import '../screens/products/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  Widget _buildImageWidget(String url) {
    if (url.trim().isEmpty) {
      return Container(
        color: AppColors.card,
        child: const Center(
          child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
        ),
      );
    }

    if (url.startsWith('data:image/')) {
      try {
        final base64Str = url.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.card,
            child: const Center(
              child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
            ),
          ),
        );
      } catch (e) {
        return Container(
          color: AppColors.card,
          child: const Center(
            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
          ),
        );
      }
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("IMAGE CARD ERROR ($url): $error");
        return Container(
          color: AppColors.card,
          child: const Center(
            child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: product.hasImages
                          ? _buildImageWidget(product.imageUrl)
                          : Container(
                              color: AppColors.card,
                              child: const Center(
                                child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 40),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, child) {
                        final isFav = wishlist.isFavorite(product.id);
                        return Material(
                          color: Colors.transparent,
                          child: IconButton(
                            iconSize: 20,
                            onPressed: () async {
                              final token = context.read<UserProvider>().user?.token;
                              if (token != null) {
                                if (isFav) {
                                  await wishlist.removeFromWishlist(product.id, token);
                                } else {
                                  await wishlist.addToWishlist(product, token);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please login to use wishlist')),
                                );
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.formattedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(color: AppColors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.stockStatusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: product.stockStatusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
