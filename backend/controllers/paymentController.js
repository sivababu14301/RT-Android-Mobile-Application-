const Razorpay = require('razorpay');
const crypto = require('crypto');
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Notification = require('../models/Notification');

// Initialize Razorpay instance safely using env vars
const getRazorpayInstance = () => {
  const key_id = process.env.RAZORPAY_KEY_ID;
  const key_secret = process.env.RAZORPAY_KEY_SECRET;

  if (!key_id || !key_secret) {
    throw new Error('Razorpay API keys not configured in server environment');
  }

  return new Razorpay({
    key_id,
    key_secret,
  });
};

// @desc    Create Razorpay Order
// @route   POST /api/payment/razorpay/order
// @access  Private
const createRazorpayOrder = async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt } = req.body;

    const checkoutTotalRupees = Math.round(Number(amount));
    const amountInPaise = Math.round(Number(amount) * 100);

    console.log(`CHECKOUT GRAND TOTAL: ₹${checkoutTotalRupees}`);
    console.log(`RAZORPAY REQUEST AMOUNT: ₹${checkoutTotalRupees}`);
    console.log(`RAZORPAY AMOUNT IN PAISE: ${amountInPaise}`);

    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment amount',
      });
    }

    const orderReceipt = receipt || `RT_${Date.now()}`;

    const instance = getRazorpayInstance();
    const options = {
      amount: amountInPaise,
      currency,
      receipt: orderReceipt,
    };

    const rzpOrder = await instance.orders.create(options);

    console.log(`RAZORPAY ORDER AMOUNT: ${rzpOrder.amount}`);

    res.status(200).json({
      success: true,
      orderId: rzpOrder.id,
      amount: rzpOrder.amount,
      currency: rzpOrder.currency,
      keyId: process.env.RAZORPAY_KEY_ID, // Safe to send public key ID only
    });
  } catch (error) {
    console.error('❌ RAZORPAY ORDER CREATION FAILED:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create Razorpay payment order',
      error: error.message,
    });
  }
};

// @desc    Verify Razorpay Payment Signature and Create Order
// @route   POST /api/payment/razorpay/verify
// @access  Private
const verifyRazorpayPayment = async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      orderData,
    } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: 'Payment verification failed: Missing required fields',
      });
    }

    console.log('RAZORPAY PAYMENT VERIFICATION STARTED:', {
      razorpay_order_id,
      razorpay_payment_id,
    });

    // Step 0: Check if order with this razorpayPaymentId already exists to prevent duplicate orders
    const existingPaymentOrder = await Order.findOne({ razorpayPaymentId: razorpay_payment_id });
    if (existingPaymentOrder) {
      console.log('⚠️ DUPLICATE PAYMENT CALLBACK RECEIVED: Order already processed', razorpay_payment_id);
      return res.status(200).json({
        success: true,
        message: 'Payment verified successfully (Order already created)',
        order: existingPaymentOrder,
      });
    }

    // Step 1: Verify HMAC SHA256 Signature using secure comparison
    const body = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest('hex');

    const isSignatureValid = crypto.timingSafeEqual(
      Buffer.from(expectedSignature),
      Buffer.from(razorpay_signature)
    );

    if (!isSignatureValid) {
      console.error('❌ RAZORPAY SIGNATURE VERIFICATION FAILED');
      return res.status(400).json({
        success: false,
        message: 'Payment verification failed',
      });
    }

    console.log('RAZORPAY PAYMENT VERIFIED');

    if (!orderData || !orderData.orderItems || orderData.orderItems.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Missing order items data',
      });
    }

    // Recalculate exact total amount from order items
    const calculatedTotal = orderData.orderItems.reduce((sum, item) => {
      return sum + (Number(item.price) * Number(item.quantity));
    }, 0);

    // Step 2: Validate Stock Availability before finalizing order
    for (const item of orderData.orderItems) {
      const pId = item.product || item.productId || item._id;
      const qty = item.quantity || item.qty || 1;

      const product = await Product.findById(pId);
      if (!product) {
        return res.status(404).json({ success: false, message: 'Product not found' });
      }

      if (product.stock < qty) {
        return res.status(400).json({
          success: false,
          message: `Only ${product.stock} items available for "${product.name}".`,
        });
      }
    }

    // Step 3: Decrement Stock in MongoDB
    for (const item of orderData.orderItems) {
      const pId = item.product || item.productId || item._id;
      const qty = item.quantity || item.qty || 1;
      await Product.findByIdAndUpdate(pId, { $inc: { stock: -qty } });
    }

    // Step 4: Create Order in MongoDB
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    let hours = now.getHours();
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12;
    const timeStr = `${String(hours).padStart(2, '0')}:${minutes} ${ampm}`;

    const order = new Order({
      orderItems: orderData.orderItems,
      user: req.user._id,
      shippingAddress: orderData.shippingAddress,
      paymentMethod: 'Razorpay',
      razorpayOrderId: razorpay_order_id,
      razorpayPaymentId: razorpay_payment_id,
      razorpaySignature: razorpay_signature,
      paymentResult: {
        id: razorpay_payment_id,
        status: 'captured',
        update_time: new Date().toISOString(),
        email_address: req.user.email,
      },
      itemsPrice: calculatedTotal,
      shippingPrice: orderData.shippingPrice || 0,
      totalPrice: calculatedTotal,
      isPaid: true,
      paidAt: now,
      status: 'Order Placed',
      statusHistory: [
        {
          status: 'Order Placed',
          date: dateStr,
          time: timeStr,
          updatedAt: now,
        },
      ],
    });

    const createdOrder = await order.save();

    // Step 5: Clear Cart
    await Cart.findOneAndDelete({ userId: req.user._id });

    // Step 6: Create initial notification for customer
    try {
      const shortId = createdOrder._id.toString().substring(createdOrder._id.toString().length - 6).toUpperCase();
      await Notification.create({
        userId: req.user._id,
        orderId: createdOrder._id,
        title: '🛍️ Order Placed Successfully',
        message: `Your order #${shortId} paid via Razorpay has been placed successfully.`,
        type: 'order_status',
        sender: 'system',
        isRead: false,
      });
    } catch (notifErr) {
      console.error('❌ NOTIFICATION CREATION ERROR:', notifErr);
    }

    console.log('ORDER PAYMENT STATUS UPDATED:', createdOrder._id);

    res.status(201).json({
      success: true,
      message: 'Payment verified successfully',
      order: createdOrder,
    });
  } catch (error) {
    console.error('❌ RAZORPAY VERIFY ERROR:', error);
    res.status(500).json({
      success: false,
      message: 'Server error verifying payment',
    });
  }
};

module.exports = {
  createRazorpayOrder,
  verifyRazorpayPayment,
};
