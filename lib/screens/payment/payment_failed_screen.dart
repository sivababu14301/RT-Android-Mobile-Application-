import 'package:flutter/material.dart';
import '../../widgets/payment/payment_button.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 100,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Failed',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong with your transaction. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 60),
            PaymentButton(
              text: 'RETRY PAYMENT',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            PaymentButton(
              text: 'BACK',
              isSecondary: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
