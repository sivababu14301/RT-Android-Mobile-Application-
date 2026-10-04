import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';
import 'cod_order_confirmed_screen.dart';
import 'payment_success_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final bool isCod;
  const PaymentProcessingScreen({super.key, this.isCod = false});

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  late Razorpay _razorpay;
  String _statusMessage = 'Initializing Checkout...';
  Map<String, dynamic>? _preparedOrderData;
  String? _authToken;
  String? _currentRzpOrderId;

  @override
  void initState() {
    super.initState();
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

  Future<void> _startCheckoutProcess() async {
    try {
      final cartProvider = context.read<CartProvider>();
      final userProvider = context.read<UserProvider>();
      final orderProvider = context.read<OrderProvider>();

      _authToken = userProvider.user?.token;
      if (_authToken == null) throw 'Authentication required. Please login again.';

      final address = userProvider.user?.address;
      if (address == null) throw 'Shipping address is required. Please add delivery address.';

      if (cartProvider.items.isEmpty) throw 'Your shopping cart is empty.';

      final double checkoutGrandTotal = cartProvider.totalAmount;
      final int amountPaiseExpected = (checkoutGrandTotal * 100).round();

      debugPrint("CHECKOUT GRAND TOTAL: ₹${checkoutGrandTotal.round()}");
      debugPrint("RAZORPAY REQUEST AMOUNT: ₹${checkoutGrandTotal.round()}");
      debugPrint("RAZORPAY AMOUNT IN PAISE: $amountPaiseExpected");

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
        'orderItems': orderItems,
        'shippingAddress': address.toJson(),
        'paymentMethod': widget.isCod ? 'COD' : 'Razorpay',
        'itemsPrice': checkoutGrandTotal,
        'shippingPrice': 0.0,
        'totalPrice': checkoutGrandTotal,
      };

      if (widget.isCod) {
        // --- COD FLOW ---
        setState(() => _statusMessage = 'Placing Cash on Delivery Order...');
        final createdOrder = await orderProvider.placeOrder(_preparedOrderData!, _authToken!);

        if (createdOrder != null && mounted) {
          debugPrint('✅ [COD ORDER CREATED]: ${createdOrder.id}');
          await cartProvider.clearCart(_authToken!);

          if (mounted) {
            // Completely clear Cart -> Address -> Checkout navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CodOrderConfirmedScreen(order: createdOrder),
              ),
              (route) => false,
            );
          }
        } else {
          throw 'The server could not create your order. Please try again.';
        }
      } else {
        // --- RAZORPAY ONLINE TEST PAYMENT FLOW ---
        setState(() => _statusMessage = 'Creating Razorpay Test Order...');
        final paymentService = PaymentService();
        final rzpOrderRes = await paymentService.createRazorpayOrder(checkoutGrandTotal, _authToken!);

        _currentRzpOrderId = rzpOrderRes['orderId'];
        final String keyId = rzpOrderRes['keyId'];
        final int rzpOrderAmount = rzpOrderRes['amount'];

        debugPrint("RAZORPAY ORDER AMOUNT: $rzpOrderAmount");

        var options = {
          'key': keyId,
          'amount': rzpOrderAmount,
          'name': 'RT - Raymaans Tailors',
          'description': 'Custom Tailored Order',
          'order_id': _currentRzpOrderId,
          'prefill': {
            'contact': userProvider.user?.mobile ?? '',
            'email': userProvider.user?.email ?? '',
            'name': userProvider.user?.fullName ?? '',
          },
          'theme': {
            'color': '#D4AF37', // Gold branding
          },
          'retry': {
            'enabled': true,
            'max_count': 3,
          },
          'send_sms_hash': true,
        };

        setState(() => _statusMessage = 'Opening Razorpay Gateway...');
        _razorpay.open(options);
      }
    } catch (e) {
      debugPrint('❌ [Checkout Error]: $e');
      if (mounted) {
        _handleErrorAndExit(e.toString());
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('RAZORPAY PAYMENT CALLBACK RECEIVED');
    debugPrint('Payment ID: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');

    setState(() {
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

      debugPrint('RAZORPAY PAYMENT VERIFIED');
      debugPrint('ORDER PAYMENT STATUS UPDATED');

      if (mounted) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.clearCart(_authToken!);

        if (mounted) {
          final String shortOrderId = createdOrder.id.length > 6
              ? createdOrder.id.substring(createdOrder.id.length - 6).toUpperCase()
              : createdOrder.id.toUpperCase();

          // Completely clear Cart -> Address -> Checkout navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: createdOrder.totalPrice,
                paymentId: response.paymentId ?? 'RP_${DateTime.now().millisecondsSinceEpoch}',
                orderId: shortOrderId,
                method: 'Razorpay Online (TEST MODE)',
              ),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [Signature Verification Failed]: $e');
      if (mounted) {
        _handleErrorAndExit('Payment Verification Failed: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ [RAZORPAY PAYMENT FAILED / CANCELLED]: Code ${response.code} | ${response.message}');
    if (mounted) {
      _handleErrorAndExit('Payment Cancelled or Failed. ${response.message ?? ""}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _handleErrorAndExit(String message) {
    String errorMsg = message;
    if (errorMsg.contains('Exception:')) {
      errorMsg = errorMsg.split('Exception:')[1].trim();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.pop(context); // Return user to Checkout screen so they can retry
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isCod) ...[
                const Icon(Icons.payment, color: AppColors.gold, size: 50),
                const SizedBox(height: 24),
              ],
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
