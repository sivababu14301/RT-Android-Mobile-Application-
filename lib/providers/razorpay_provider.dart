import 'package:flutter/material.dart';

enum RazorpayState { initial, loading, success, failed, cancelled }

class RazorpayProvider with ChangeNotifier {
  RazorpayState _state = RazorpayState.initial;
  String _selectedMethod = 'Razorpay'; // Default to Razorpay

  RazorpayState get state => _state;
  String get selectedMethod => _selectedMethod;

  void setMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<void> startPayment() async {
    _state = RazorpayState.loading;
    notifyListeners();

    // Simulate API/SDK loading delay
    await Future.delayed(const Duration(seconds: 3));

    // For demo purposes, we default to success
    _state = RazorpayState.success;
    notifyListeners();
  }

  void reset() {
    _state = RazorpayState.initial;
    notifyListeners();
  }

  void setStatus(RazorpayState status) {
    _state = status;
    notifyListeners();
  }
}
