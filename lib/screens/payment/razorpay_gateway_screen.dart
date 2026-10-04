import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/razorpay_provider.dart';
import '../../widgets/payment_option_tile.dart';
import '../../widgets/razorpay_details_card.dart';
import '../../widgets/razorpay_status_view.dart';

class RazorpayGatewayScreen extends StatelessWidget {
  const RazorpayGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Secure Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<RazorpayProvider>(
        builder: (context, provider, child) {
          // 1. Loading Animation View
          if (provider.state == RazorpayState.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.gold),
                  SizedBox(height: 24),
                  Text(
                    'Contacting Payment Gateway...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          // 2. Status Result View
          if (provider.state != RazorpayState.initial) {
            bool isSuccess = provider.state == RazorpayState.success;
            String message = isSuccess 
                ? 'Your order has been placed successfully.' 
                : (provider.state == RazorpayState.cancelled 
                    ? 'Payment was cancelled.' 
                    : 'Payment failed. Please try again.');
            
            return RazorpayStatusView(
              isSuccess: isSuccess,
              message: message,
              onAction: () {
                if (isSuccess) {
                  // Navigate to orders or home
                  Navigator.pop(context);
                } else {
                  provider.reset();
                }
              },
            );
          }

          // 3. Selection View
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                PaymentOptionTile(
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when your order is delivered',
                  icon: Icons.payments_outlined,
                  isSelected: provider.selectedMethod == 'COD',
                  onTap: () => provider.setMethod('COD'),
                ),
                
                PaymentOptionTile(
                  title: 'Razorpay',
                  subtitle: 'Pay securely using Razorpay',
                  icon: Icons.account_balance_wallet_outlined,
                  isSelected: provider.selectedMethod == 'Razorpay',
                  onTap: () => provider.setMethod('Razorpay'),
                ),

                const SizedBox(height: 12),

                // Razorpay Specific Card
                if (provider.selectedMethod == 'Razorpay')
                  const RazorpayDetailsCard(amount: 1150.00),

                const SizedBox(height: 48),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (provider.selectedMethod == 'Razorpay') {
                        provider.startPayment();
                      } else {
                        // For COD, just show success directly
                        provider.setStatus(RazorpayState.success);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: AppColors.gold.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      provider.selectedMethod == 'Razorpay' ? 'PAY NOW' : 'PLACE ORDER',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL ORDER',
                      style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
