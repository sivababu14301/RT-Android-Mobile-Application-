const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Category = require('../models/Category');

// Utility to define "valid" orders (all except Cancelled)
const validOrderFilter = { status: { $ne: 'Cancelled' } };

// @desc    Get reports summary (Total, Today, Weekly, Monthly Revenue)
// @route   GET /api/admin/reports/summary (also mapped to /revenue)
// @access  Private/Admin
exports.getSummary = async (req, res) => {
  try {
    console.log("📊 REPORT REVENUE API HIT");

    const totalOrders = await Order.countDocuments();
    const validOrdersCount = await Order.countDocuments(validOrderFilter);

    const totalCustomers = await User.countDocuments({ role: 'customer' });
    const totalProducts = await Product.countDocuments();
    const pendingOrders = await Order.countDocuments({ status: 'Pending' });
    const completedOrders = await Order.countDocuments({ status: 'Delivered' });
    const cancelledOrders = await Order.countDocuments({ status: 'Cancelled' });

    // Calculate Revenue from all VALID orders (not just Delivered)
    const allValidOrders = await Order.find(validOrderFilter);
    const totalRevenue = allValidOrders.reduce((acc, order) => acc + (order.totalPrice || 0), 0);

    // Today's Revenue
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    const todayOrders = await Order.find({
      ...validOrderFilter,
      createdAt: { $gte: startOfToday }
    });
    const todayRevenue = todayOrders.reduce((acc, order) => acc + (order.totalPrice || 0), 0);

    // Weekly Revenue
    const startOfWeek = new Date();
    startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
    startOfWeek.setHours(0, 0, 0, 0);
    const weeklyOrders = await Order.find({
      ...validOrderFilter,
      createdAt: { $gte: startOfWeek }
    });
    const weeklyRevenue = weeklyOrders.reduce((acc, order) => acc + (order.totalPrice || 0), 0);

    // Monthly Revenue
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);
    const monthlyOrders = await Order.find({
      ...validOrderFilter,
      createdAt: { $gte: startOfMonth }
    });
    const monthlyRevenue = monthlyOrders.reduce((acc, order) => acc + (order.totalPrice || 0), 0);

    console.log(`✅ TOTAL ORDERS FOUND: ${totalOrders}`);
    console.log(`✅ VALID ORDERS: ${validOrdersCount}`);
    console.log(`✅ TOTAL REVENUE: ${totalRevenue}`);

    res.status(200).json({
      success: true,
      data: {
        totalCustomers,
        totalProducts,
        totalOrders,
        pendingOrders,
        completedOrders,
        cancelledOrders,
        totalRevenue,
        todayRevenue,
        weeklyRevenue,
        monthlyRevenue
      }
    });
  } catch (error) {
    console.error("❌ SUMMARY REPORT ERROR:", error);
    res.status(500).json({ success: false, message: "Summary: " + error.message });
  }
};

// @desc    Get best selling products
// @route   GET /api/admin/reports/top-products
// @access  Private/Admin
exports.getTopProducts = async (req, res) => {
  try {
    const products = await Order.aggregate([
      { $match: validOrderFilter },
      { $unwind: "$orderItems" },
      {
        $group: {
          _id: "$orderItems.product",
          name: { $first: "$orderItems.name" },
          totalSold: { $sum: "$orderItems.quantity" },
          revenue: { $sum: { $multiply: ["$orderItems.price", "$orderItems.quantity"] } }
        }
      },
      { $sort: { totalSold: -1 } },
      { $limit: 10 }
    ]);

    console.log("✅ TOP PRODUCTS GENERATED");
    res.status(200).json({ success: true, data: products });
  } catch (error) {
    console.error("❌ TOP PRODUCTS ERROR:", error);
    res.status(500).json({ success: false, message: "Top Products: " + error.message });
  }
};

// @desc    Get sales summary by category
// @route   GET /api/admin/reports/sales-summary
// @access  Private/Admin
exports.getSalesSummary = async (req, res) => {
  try {
    const categories = await Order.aggregate([
      { $match: validOrderFilter },
      { $unwind: "$orderItems" },
      {
        $lookup: {
          from: "products",
          localField: "orderItems.product",
          foreignField: "_id",
          as: "productDetails"
        }
      },
      { $unwind: { path: "$productDetails", preserveNullAndEmptyArrays: true } },
      {
        $group: {
          _id: { $ifNull: ["$productDetails.category", "Uncategorized"] },
          count: { $sum: "$orderItems.quantity" },
          revenue: { $sum: { $multiply: ["$orderItems.price", "$orderItems.quantity"] } }
        }
      }
    ]);

    console.log("✅ SALES SUMMARY GENERATED");
    res.status(200).json({ success: true, data: categories });
  } catch (error) {
    console.error("❌ SALES SUMMARY ERROR:", error);
    res.status(500).json({ success: false, message: "Sales Summary: " + error.message });
  }
};

// @desc    Get revenue by payment method
// @route   GET /api/admin/reports/payment-methods
// @access  Private/Admin
exports.getPaymentMethodsReport = async (req, res) => {
  try {
    const paymentMethods = await Order.aggregate([
      { $match: validOrderFilter },
      {
        $group: {
          _id: "$paymentMethod",
          total: { $sum: "$totalPrice" },
          count: { $sum: 1 }
        }
      }
    ]);

    console.log("✅ PAYMENT SUMMARY GENERATED");
    res.status(200).json({ success: true, data: paymentMethods });
  } catch (error) {
    console.error("❌ PAYMENT METHODS ERROR:", error);
    res.status(500).json({ success: false, message: "Payment Methods: " + error.message });
  }
};

// Trend data functions (keep existing ones if needed)
exports.getRevenueTrend = async (req, res) => {
  try {
    const revenue = await Order.aggregate([
      { $match: validOrderFilter },
      {
        $group: {
          _id: { $month: "$createdAt" },
          total: { $sum: "$totalPrice" }
        }
      },
      { $sort: { "_id": 1 } }
    ]);
    res.status(200).json({ success: true, data: revenue });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getOrdersTrend = async (req, res) => {
  try {
    const orders = await Order.aggregate([
      {
        $group: {
          _id: { $month: "$createdAt" },
          count: { $sum: 1 }
        }
      },
      { $sort: { "_id": 1 } }
    ]);
    res.status(200).json({ success: true, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
