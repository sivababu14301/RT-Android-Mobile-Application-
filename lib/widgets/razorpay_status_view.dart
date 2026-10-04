import 'package:flutter/material.dart';

class RazorpayStatusView extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onAction;

  const RazorpayStatusView({
    super.key,
    required this.isSuccess,
    required this.message,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: color,
                  size: 100,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isSuccess ? 'Payment Successful' : 'Payment Failed',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(isSuccess ? 'VIEW ORDER' : 'RETRY PAYMENT', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
