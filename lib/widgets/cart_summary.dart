import 'package:flutter/material.dart';
import '../config/app_colors.dart';

import '../screens/payment/address_screen.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;

  const CartSummary({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppColors.grey)),
              Text('₹${subtotal.toInt()}', style: const TextStyle(color: AppColors.white)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery', style: TextStyle(color: AppColors.grey)),
              Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white12, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${subtotal.toInt()}',
                style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
