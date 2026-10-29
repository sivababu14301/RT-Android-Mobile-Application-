const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Notification = require('../models/Notification');
const User = require('../models/User');

const formatDateTime = (now = new Date()) => {
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const dateStr = `${year}-${month}-${day}`;

  let hours = now.getHours();
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours ? hours : 12;
  const timeStr = `${String(hours).padStart(2, '0')}:${minutes} ${ampm}`;

  return { date: dateStr, time: timeStr, updatedAt: now };
};

const getStatusNotificationContent = (status, orderId, extraData = {}) => {
  const shortId = orderId.toString().length > 6
    ? orderId.toString().substring(orderId.toString().length - 6).toUpperCase()
    : orderId.toString().toUpperCase();

  switch (status.trim().toLowerCase()) {
    case 'cancellation requested':
      return {
        title: '⌛ Cancellation Request Submitted',
        message: `Your cancellation request for order #${shortId} has been sent to admin for approval.`
      };
    case 'cancellation_approved':
      return {
        title: '✅ Order Cancellation Approved',
        message: `Your cancellation request for order #${shortId} was approved and the order has been cancelled.`
      };
    case 'cancellation_rejected':
      return {
        title: '❌ Order Cancellation Request Rejected',
        message: `Your cancellation request for order #${shortId} was rejected. Reason: ${extraData.reason || 'Order processing has already started.'}`
      };
    case 'confirmed':
    case 'order confirmed':
      return {
        title: '✅ Order Confirmed',
        message: `Your order #${shortId} has been confirmed.`
      };
    case 'processing':
      return {
        title: '⚙️ Order Processing Started',
        message: `Your order #${shortId} is now being processed.`
      };
    case 'stitching':
      return {
        title: '🧵 Order Stitching in Progress',
        message: `Your order #${shortId} is currently being stitched.`
      };
    case 'ready':
      return {
        title: '🔔 Order Ready for Delivery',
        message: `Your order #${shortId} is ready for delivery.`
      };
    case 'out for delivery':
    case 'out_for_delivery':
      return {
        title: '🚚 Order Out for Delivery',
        message: `Your order #${shortId} is out for delivery.`
      };
    case 'delivered':
      return {
        title: '🏠 Order Delivered',
        message: `Your order #${shortId} has been delivered.`
      };
    case 'cancelled':
      return {
        title: '❌ Order Cancelled',
        message: `Your order #${shortId} has been cancelled.`
      };
    default:
      return {
        title: `📦 Order Status Updated: ${status}`,
        message: `Your order #${shortId} status has been updated to ${status}.`
      };
  }
};

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
const addOrderItems = async (req, res) => {
  try {
    const {
      idempotencyKey,
      orderItems,
      shippingAddress,
      paymentMethod,
      itemsPrice,
      shippingPrice,
      totalPrice,
    } = req.body;

    if (!orderItems || orderItems.length === 0) {
      return res.status(400).json({ success: false, message: 'No order items provided' });
    }

    // Deduplication check: Prevent duplicate orders on network retries
    if (idempotencyKey || req.user?._id) {
      const existingOrder = await Order.findOne({
        user: req.user._id,
        paymentMethod,
        totalPrice,
        createdAt: { $gte: new Date(Date.now() - 10 * 60 * 1000) }
      });
      if (existingOrder) {
        console.log(`ℹ️ [Order Controller] Idempotency Match Found: Existing Order ${existingOrder._id}`);
        return res.status(200).json({
          success: true,
          order: existingOrder,
          message: 'Existing order retrieved successfully'
        });
      }
    }

    // Validate stock
    for (const item of orderItems) {
      const pId = item.product || item.productId || item._id;
      const qty = item.quantity || item.qty || 1;

      const product = await Product.findById(pId);
      if (!product) {
        return res.status(404).json({ success: false, message: `Product not found` });
      }

      if (product.stock < qty) {
        return res.status(400).json({
          success: false,
          message: product.stock <= 0
            ? `"${product.name}" is currently Out of Stock.`
            : `Only ${product.stock} items available for "${product.name}".`
        });
      }
    }

    // Decrement stock
    for (const item of orderItems) {
      const pId = item.product || item.productId || item._id;
      const qty = item.quantity || item.qty || 1;
      await Product.findByIdAndUpdate(pId, { $inc: { stock: -qty } });
    }

    const { date, time, updatedAt } = formatDateTime(new Date());

    const order = new Order({
      orderItems,
      user: req.user._id,
      shippingAddress,
      paymentMethod,
      itemsPrice,
      shippingPrice,
      totalPrice,
      status: 'Pending',
      statusHistory: [
        {
          status: 'Pending',
          date,
          time,
          updatedAt
        }
      ]
    });

    const createdOrder = await order.save();

    await Cart.findOneAndDelete({ userId: req.user._id });

    // Send initial in-app notification
    try {
      await Notification.create({
        userId: req.user._id,
        orderId: createdOrder._id,
        title: '🛍️ Order Placed Successfully',
        message: `Your order #${createdOrder._id.toString().slice(-6).toUpperCase()} has been placed successfully and is currently Pending.`,
        type: 'order_status',
        sender: 'system',
        isRead: false
      });
    } catch (notifErr) {
      console.error('❌ ORDER PLACED NOTIFICATION ERROR:', notifErr.message);
    }

    res.status(201).json({
      success: true,
      order: createdOrder
    });
  } catch (error) {
    console.error('ADD ORDER ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get order by ID
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('user', 'name email mobile');

    if (order) {
      if (order.user._id.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
        return res.status(403).json({ success: false, message: 'Not authorized to view this order' });
      }
      res.json({ success: true, order });
    } else {
      res.status(404).json({ success: false, message: 'Order not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update order to paid
// @route   PUT /api/orders/:id/pay
// @access  Private
const updateOrderToPaid = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (order) {
      order.isPaid = true;
      order.paidAt = Date.now();
      order.paymentResult = {
        id: req.body.id,
        status: req.body.status,
        update_time: req.body.update_time,
        email_address: req.body.email_address,
      };

      const updatedOrder = await order.save();
      res.json({ success: true, order: updatedOrder });
    } else {
      res.status(404).json({ success: false, message: 'Order not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get logged in user orders
// @route   GET /api/orders/my-orders
// @access  Private
const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all orders
// @route   GET /api/orders
// @access  Private/Admin
const getOrders = async (req, res) => {
  try {
    const orders = await Order.find({}).populate('user', 'id name email mobile').sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update order status by Admin
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.status === 'Cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update status for a cancelled order.'
      });
    }

    // REQUIREMENT 3: If a cancellation request is pending, prevent processing status update
    if (order.status === 'Cancellation Requested') {
      return res.status(400).json({
        success: false,
        message: 'A cancellation request is currently pending for this order. Please approve or reject the cancellation request first.'
      });
    }

    const previousStatus = order.status || '';

    if (previousStatus.trim().toLowerCase() === status.trim().toLowerCase()) {
      return res.json({ success: true, order });
    }

    order.status = status;
    if (status === 'Delivered') {
      order.isDelivered = true;
      order.deliveredAt = Date.now();
    }

    const { date, time, updatedAt } = formatDateTime(new Date());
    if (!order.statusHistory) order.statusHistory = [];

    const existingIdx = order.statusHistory.findIndex(
      h => h.status.toLowerCase() === status.toLowerCase()
    );

    if (existingIdx !== -1) {
      order.statusHistory[existingIdx].date = date;
      order.statusHistory[existingIdx].time = time;
      order.statusHistory[existingIdx].updatedAt = updatedAt;
    } else {
      order.statusHistory.push({ status, date, time, updatedAt });
    }

    const updatedOrder = await order.save();

    // Send in-app notification
    try {
      const notifContent = getStatusNotificationContent(status, order._id);
      await Notification.create({
        userId: order.user,
        orderId: order._id,
        title: notifContent.title,
        message: notifContent.message,
        type: 'order_status',
        sender: 'system',
        isRead: false
      });
    } catch (notifErr) {
      console.error('❌ NOTIFICATION CREATION ERROR:', notifErr.message);
    }

    res.json({ success: true, order: updatedOrder });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Customer submits a cancellation request (Allowed ONLY when status is "Pending" / "Order Placed")
// @route   PUT /api/orders/:id/cancel-request
// @access  Private
const requestOrderCancellation = async (req, res) => {
  try {
    const { reason } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Validate ownership
    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized to cancel this order' });
    }

    // Check if cancellation request already pending
    if (order.status === 'Cancellation Requested') {
      return res.status(400).json({
        success: false,
        message: 'Your cancellation request has already been sent to the admin for approval.'
      });
    }

    // REQUIREMENT 1 & 3: Allow cancellation request ONLY when status is "Pending" or "Order Placed"
    const allowedStatuses = ['Pending', 'Order Placed'];
    if (!allowedStatuses.includes(order.status)) {
      return res.status(400).json({
        success: false,
        message: 'Order cancellation is not allowed as order processing has already started.'
      });
    }

    const { date, time, updatedAt } = formatDateTime(new Date());

    // Atomic update to prevent race conditions
    const updatedOrder = await Order.findOneAndUpdate(
      {
        _id: req.params.id,
        user: req.user._id,
        status: { $in: allowedStatuses }
      },
      {
        $set: {
          status: 'Cancellation Requested',
          cancellationReason: reason || 'Customer requested cancellation',
          cancellationRequestedAt: new Date()
        },
        $push: {
          statusHistory: { status: 'Cancellation Requested', date, time, updatedAt }
        }
      },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(400).json({
        success: false,
        message: 'Order cancellation is not allowed as order processing has already started.'
      });
    }

    // Send in-app notification to customer
    try {
      const notifContent = getStatusNotificationContent('Cancellation Requested', updatedOrder._id);
      await Notification.create({
        userId: updatedOrder.user,
        orderId: updatedOrder._id,
        title: notifContent.title,
        message: notifContent.message,
        type: 'order_status',
        sender: 'system',
        isRead: false
      });
    } catch (notifErr) {
      console.error('❌ CANCEL REQUEST NOTIFICATION ERROR:', notifErr.message);
    }

    res.json({
      success: true,
      message: 'Your cancellation request has been sent to the admin for approval.',
      order: updatedOrder
    });
  } catch (error) {
    console.error('CANCEL REQUEST ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Admin approves cancellation request and sets order status to "Cancelled"
// @route   PUT /api/orders/:id/approve-cancellation
// @access  Private/Admin
const approveOrderCancellation = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.status === 'Cancelled') {
      return res.status(400).json({ success: false, message: 'Order is already cancelled' });
    }

    const { date, time, updatedAt } = formatDateTime(new Date());

    order.status = 'Cancelled';
    if (!order.statusHistory) order.statusHistory = [];
    order.statusHistory.push({ status: 'Cancelled', date, time, updatedAt });

    // Safely restore stock ONLY once
    if (!order.isStockRestored && order.orderItems && order.orderItems.length > 0) {
      for (const item of order.orderItems) {
        const pId = item.product || item.productId || item._id;
        const qty = item.quantity || item.qty || 1;
        await Product.findByIdAndUpdate(pId, { $inc: { stock: qty } });
      }
      order.isStockRestored = true;
    }

    const updatedOrder = await order.save();

    // Send notification to customer
    try {
      const notifContent = getStatusNotificationContent('cancellation_approved', updatedOrder._id);
      await Notification.create({
        userId: updatedOrder.user,
        orderId: updatedOrder._id,
        title: notifContent.title,
        message: notifContent.message,
        type: 'order_status',
        sender: 'system',
        isRead: false
      });
    } catch (notifErr) {
      console.error('❌ APPROVE CANCEL NOTIFICATION ERROR:', notifErr.message);
    }

    res.json({
      success: true,
      message: 'Cancellation approved successfully and stock restored.',
      order: updatedOrder
    });
  } catch (error) {
    console.error('APPROVE CANCEL ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Admin rejects cancellation request and reverts status to "Pending"
// @route   PUT /api/orders/:id/reject-cancellation
// @access  Private/Admin
const rejectOrderCancellation = async (req, res) => {
  try {
    const { reason } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.status !== 'Cancellation Requested') {
      return res.status(400).json({ success: false, message: 'No pending cancellation request for this order' });
    }

    const { date, time, updatedAt } = formatDateTime(new Date());

    const rejectionReason = reason || 'Order processing has already started.';
    order.status = 'Pending';
    order.cancellationRejectionReason = rejectionReason;

    if (!order.statusHistory) order.statusHistory = [];
    order.statusHistory.push({ status: 'Pending', date, time, updatedAt });

    const updatedOrder = await order.save();

    // Send notification to customer with rejection reason
    try {
      const notifContent = getStatusNotificationContent('cancellation_rejected', updatedOrder._id, { reason: rejectionReason });
      await Notification.create({
        userId: updatedOrder.user,
        orderId: updatedOrder._id,
        title: notifContent.title,
        message: notifContent.message,
        type: 'order_status',
        sender: 'system',
        isRead: false
      });
    } catch (notifErr) {
      console.error('❌ REJECT CANCEL NOTIFICATION ERROR:', notifErr.message);
    }

    res.json({
      success: true,
      message: 'Cancellation request rejected. Order status set back to Pending.',
      order: updatedOrder
    });
  } catch (error) {
    console.error('REJECT CANCEL ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addOrderItems,
  getOrderById,
  updateOrderToPaid,
  getMyOrders,
  getOrders,
  updateOrderStatus,
  requestOrderCancellation,
  approveOrderCancellation,
  rejectOrderCancellation,
};
