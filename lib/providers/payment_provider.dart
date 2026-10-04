import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentProvider with ChangeNotifier {
  PaymentMethodType _selectedMethod = PaymentMethodType.razorpay;

  PaymentMethodType get selectedMethod => _selectedMethod;

  void selectMethod(PaymentMethodType method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void reset() {
    _selectedMethod = PaymentMethodType.razorpay;
    notifyListeners();
  }
}
