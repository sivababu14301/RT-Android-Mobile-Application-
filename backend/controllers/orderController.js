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

const getStatusNotificationContent = (status, orderId) => {
  const shortId = orderId.toString().length > 6
    ? orderId.toString().substring(orderId.toString().length - 6).toUpperCase()
    : orderId.toString().toUpperCase();

  switch (status.trim().toLowerCase()) {
    case 'confirmed':
    case 'order confirmed':
      return {
        title: '✅ Order Confirmed',
        message: `Your order #${shortId} has been confirmed.`
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
      status: 'Order Placed',
      statusHistory: [
        {
          status: 'Order Placed',
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
        message: `Your order #${createdOrder._id.toString().slice(-6).toUpperCase()} has been placed successfully.`,
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
    const order = await Order.findById(req.params.id).populate('user', 'name email');

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
    const orders = await Order.find({}).populate('user', 'id name').sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);

    if (order) {
      const previousStatus = order.status || '';

      // Prevent duplicate notification if status hasn't changed
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

      // In-App Notification in MongoDB
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
    } else {
      res.status(404).json({ success: false, message: 'Order not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Cancel order
// @route   PUT /api/orders/:id/cancel
// @access  Private
const cancelOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (order) {
      if (order.user.toString() !== req.user._id.toString()) {
        return res.status(401).json({ success: false, message: 'Not authorized to cancel this order' });
      }

      const cancellableStatuses = ['Pending', 'Order Placed', 'Confirmed', 'Order Confirmed'];
      if (!cancellableStatuses.includes(order.status)) {
        return res.status(400).json({
          success: false,
          message: `Cannot cancel order in '${order.status}' status. Tailoring may have already started.`
        });
      }

      // Restore stock
      if (order.orderItems && order.orderItems.length > 0) {
        for (const item of order.orderItems) {
          const pId = item.product || item.productId || item._id;
          const qty = item.quantity || item.qty || 1;
          await Product.findByIdAndUpdate(pId, { $inc: { stock: qty } });
        }
      }

      order.status = 'Cancelled';

      const { date, time, updatedAt } = formatDateTime(new Date());
      if (!order.statusHistory) order.statusHistory = [];
      order.statusHistory.push({ status: 'Cancelled', date, time, updatedAt });

      const updatedOrder = await order.save();

      try {
        const notifContent = getStatusNotificationContent('Cancelled', order._id);
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
        console.error('❌ CANCEL NOTIFICATION ERROR:', notifErr.message);
      }

      res.json({ success: true, order: updatedOrder });
    } else {
      res.status(404).json({ success: false, message: 'Order not found' });
    }
  } catch (error) {
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
  cancelOrder,
};
