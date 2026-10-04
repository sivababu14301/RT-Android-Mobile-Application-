import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      isLoading: true,
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.black),
          SizedBox(height: 8),
          ShimmerPlaceholder(width: 50, height: 10),
        ],
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder(width: 100, height: 15),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 60, height: 15),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 40, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(width: 60, height: 60, color: Colors.black),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder(width: 150, height: 15),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 100, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
