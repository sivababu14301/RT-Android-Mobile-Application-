import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';
import 'cod_order_confirmed_screen.dart';
import 'payment_success_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final bool isCod;
  final PaymentMethodType preferredMethod;

  const PaymentProcessingScreen({
    super.key,
    this.isCod = false,
    this.preferredMethod = PaymentMethodType.razorpay,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  late Razorpay _razorpay;
  String _statusMessage = 'Initializing Checkout...';
  bool _isProcessing = true;
  String? _errorMessage;
  Map<String, dynamic>? _preparedOrderData;
  String? _authToken;
  String? _currentRzpOrderId;
  String? _idempotencyKey;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = 'RT_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    if (!widget.isCod) {
      _initRazorpay();
    }
    _startCheckoutProcess();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    if (!widget.isCod) {
      _razorpay.clear();
    }
    super.dispose();
  }

  String _getPaymentMethodLabel() {
    switch (widget.preferredMethod) {
      case PaymentMethodType.googlePay:
        return 'Google Pay UPI';
      case PaymentMethodType.phonePe:
        return 'PhonePe UPI';
      case PaymentMethodType.paytm:
        return 'Paytm UPI/Wallet';
      case PaymentMethodType.bhimUpi:
        return 'BHIM / UPI ID';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
      case PaymentMethodType.razorpay:
        return 'Razorpay Online';
      case PaymentMethodType.cod:
        return 'COD';
    }
  }

  Map<String, dynamic> _buildRazorpayOptions({
    required String keyId,
    required int rzpOrderAmount,
    required String orderId,
    required UserProvider userProvider,
  }) {
    final String userMobile = userProvider.user?.mobile ?? '';
    final String userEmail = userProvider.user?.email ?? '';
    final String userName = userProvider.user?.fullName ?? '';

    final Map<String, dynamic> prefillMap = {
      'contact': userMobile,
      'email': userEmail,
      'name': userName,
    };

    final options = <String, dynamic>{
      'key': keyId,
      'amount': rzpOrderAmount,
      'name': 'RT - Raymaans Tailors',
      'description': 'Order Payment via ${_getPaymentMethodLabel()}',
      'order_id': orderId,
      'prefill': prefillMap,
      'theme': {
        'color': '#D4AF37', // Gold branding
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      'send_sms_hash': true,
    };

    switch (widget.preferredMethod) {
      case PaymentMethodType.googlePay:
        options['method'] = 'upi';
        options['upi'] = {
          'flow': 'intent',
          'app': 'com.google.android.apps.nbu.paisa.user',
        };
        break;

      case PaymentMethodType.phonePe:
        options['method'] = 'upi';
        options['upi'] = {
          'flow': 'intent',
          'app': 'com.phonepe.app',
        };
        break;

      case PaymentMethodType.paytm:
        options['method'] = 'upi';
        options['upi'] = {
          'flow': 'intent',
          'app': 'net.one97.paytm',
        };
        break;

      case PaymentMethodType.bhimUpi:
        options['method'] = 'upi';
        break;

      case PaymentMethodType.card:
        options['method'] = 'card';
        break;

      case PaymentMethodType.netBanking:
        options['method'] = 'netbanking';
        break;

      case PaymentMethodType.razorpay:
      case PaymentMethodType.cod:
        break;
    }

    return options;
  }

  Future<void> _startCheckoutProcess() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _statusMessage = widget.isCod
          ? 'Validating order and address details...'
          : 'Initializing ${_getPaymentMethodLabel()} checkout...';
    });

    try {
      final cartProvider = context.read<CartProvider>();
      final userProvider = context.read<UserProvider>();
      final orderProvider = context.read<OrderProvider>();

      _authToken = userProvider.user?.token;
      if (_authToken == null) throw 'Authentication required. Please login again.';

      final address = userProvider.user?.address;
      if (address == null || address.fullAddress.trim().isEmpty) {
        throw 'Shipping address is required. Please add delivery address.';
      }

      if (cartProvider.items.isEmpty) throw 'Your shopping cart is empty.';

      final double checkoutGrandTotal = cartProvider.totalAmount;

      debugPrint("CHECKOUT GRAND TOTAL: ₹${checkoutGrandTotal.round()}");
      debugPrint("IDEMPOTENCY KEY: $_idempotencyKey");

      // Map cart items to backend order items structure
      final orderItems = cartProvider.items.map((item) {
        String itemImage = '';
        if (item.product.images.isNotEmpty) {
          itemImage = item.product.images[0];
        }

        return {
          'name': item.product.name,
          'quantity': item.quantity,
          'image': itemImage,
          'price': item.product.price,
          'size': item.size,
          'color': item.color,
          'product': item.product.id,
        };
      }).toList();

      _preparedOrderData = {
        'idempotencyKey': _idempotencyKey,
        'orderItems': orderItems,
        'shippingAddress': address.toJson(),
        'paymentMethod': _getPaymentMethodLabel(),
        'itemsPrice': checkoutGrandTotal,
        'shippingPrice': 0.0,
        'totalPrice': checkoutGrandTotal,
      };

      if (widget.isCod) {
        // --- COD FLOW ---
        setState(() => _statusMessage = 'Placing Cash on Delivery Order...');
        
        // Check if order was already saved to prevent duplicate creation
        await orderProvider.fetchMyOrders(_authToken!);
        final existingOrder = _findExistingOrder(orderProvider.orders);

        OrderModel? createdOrder = existingOrder;
        if (createdOrder == null) {
          createdOrder = await orderProvider.placeOrder(_preparedOrderData!, _authToken!);
        }

        if (createdOrder != null && mounted) {
          debugPrint('✅ [COD ORDER CONFIRMED]: ${createdOrder.id}');
          await cartProvider.clearCart(_authToken!);

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CodOrderConfirmedScreen(order: createdOrder!),
              ),
              (route) => false,
            );
          }
        } else {
          throw 'Server failed to finalize Cash on Delivery order. Please retry.';
        }
      } else {
        // --- RAZORPAY / UPI ONLINE PAYMENT FLOW ---
        setState(() => _statusMessage = 'Creating Razorpay Order...');
        final paymentService = PaymentService();
        final rzpOrderRes = await paymentService.createRazorpayOrder(checkoutGrandTotal, _authToken!);

        _currentRzpOrderId = rzpOrderRes['orderId'];
        final String keyId = rzpOrderRes['keyId'];
        final int rzpOrderAmount = rzpOrderRes['amount'];

        final options = _buildRazorpayOptions(
          keyId: keyId,
          rzpOrderAmount: rzpOrderAmount,
          orderId: _currentRzpOrderId!,
          userProvider: userProvider,
        );

        setState(() => _statusMessage = 'Launching ${_getPaymentMethodLabel()}...');
        _razorpay.open(options);
      }
    } catch (e) {
      debugPrint('❌ [Checkout Error]: $e');
      if (mounted) {
        _handleCheckoutError(e.toString());
      }
    }
  }

  OrderModel? _findExistingOrder(List<OrderModel> orders) {
    if (_preparedOrderData == null) return null;
    final total = (_preparedOrderData!['totalPrice'] as num).toDouble();

    for (var o in orders) {
      if ((o.totalPrice - total).abs() < 1.0) {
        final diff = DateTime.now().difference(o.createdAt);
        if (diff.inMinutes < 10) {
          return o;
        }
      }
    }
    return null;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('RAZORPAY PAYMENT CALLBACK RECEIVED');
    debugPrint('Payment ID: ${response.paymentId}');

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying Payment Signature with Server...';
    });

    try {
      final paymentService = PaymentService();
      final createdOrder = await paymentService.verifyRazorpayPayment(
        razorpayOrderId: response.orderId ?? _currentRzpOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        orderData: _preparedOrderData!,
        token: _authToken!,
      );

      debugPrint('RAZORPAY PAYMENT VERIFIED & ORDER FINALIZED');

      if (mounted) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.clearCart(_authToken!);

        if (mounted) {
          final String shortOrderId = createdOrder.id.length > 6
              ? createdOrder.id.substring(createdOrder.id.length - 6).toUpperCase()
              : createdOrder.id.toUpperCase();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: createdOrder.totalPrice,
                paymentId: response.paymentId ?? 'RP_${DateTime.now().millisecondsSinceEpoch}',
                orderId: shortOrderId,
                method: _getPaymentMethodLabel(),
              ),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [Signature Verification Failed]: $e');
      if (mounted) {
        _handleCheckoutError('Payment Verification Failed: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ [RAZORPAY PAYMENT FAILED]: ${response.code} | ${response.message}');
    String message = response.message ?? 'Payment failed or was cancelled.';

    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      message = 'Payment was cancelled. You can retry or choose another payment method.';
    } else if (response.code == Razorpay.NETWORK_ERROR) {
      message = 'Network Error: Please check your internet connection and try again.';
    } else if (message.toLowerCase().contains('app not found') || message.toLowerCase().contains('app not installed')) {
      message = 'The selected UPI app is not installed on this device. Please select another payment option or enter a UPI ID.';
    }

    if (mounted) {
      _handleCheckoutError(message);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _handleCheckoutError(String rawError) {
    String errorMsg = rawError;
    if (errorMsg.contains('receive timeout')) {
      errorMsg = 'Connection Timeout: The server took too long to respond. Please verify your network and tap Retry.';
    } else if (errorMsg.contains('connectionTimeout') || errorMsg.contains('connection error')) {
      errorMsg = 'Connection Error: Could not reach the server. Please check your internet connection.';
    } else if (errorMsg.contains('Exception:')) {
      errorMsg = errorMsg.split('Exception:')[1].trim();
    }

    setState(() {
      _isProcessing = false;
      _errorMessage = errorMsg;
    });
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
        title: Text(
          widget.isCod ? 'Cash on Delivery Checkout' : '${_getPaymentMethodLabel()} Checkout',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              if (_isProcessing) ...[
                const Icon(Icons.payment_outlined, color: AppColors.gold, size: 60),
                const SizedBox(height: 28),
                const CircularProgressIndicator(color: AppColors.gold),
                const SizedBox(height: 32),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please do not close or leave the app during checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ] else ...[
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Checkout Could Not Complete',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage ?? 'An unexpected error occurred during checkout.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startCheckoutProcess,
                    icon: const Icon(Icons.refresh, color: Colors.black),
                    label: const Text('RETRY CHECKOUT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey,
                      side: const BorderSide(color: AppColors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('BACK TO PAYMENT METHODS'),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
