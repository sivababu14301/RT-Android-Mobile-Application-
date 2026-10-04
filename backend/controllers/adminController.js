const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Measurement = require('../models/Measurement');

// Utility to define "valid" orders (all except Cancelled)
const validOrderFilter = { status: { $ne: 'Cancelled' } };

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard
// @access  Private/Admin
const getDashboardStats = async (req, res) => {
  try {
    const totalCustomers = await User.countDocuments({ role: 'customer' });
    const totalProducts = await Product.countDocuments();
    const pendingOrders = await Order.countDocuments({ status: 'Pending' });

    // Include all VALID orders in total revenue for the dashboard too
    const allValidOrders = await Order.find(validOrderFilter);
    const totalRevenue = allValidOrders.reduce((acc, order) => acc + (order.totalPrice || 0), 0);

    res.status(200).json({
      success: true,
      totalCustomers,
      totalProducts,
      pendingOrders,
      totalRevenue
    });
  } catch (error) {
    console.error('❌ GET DASHBOARD STATS ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all customers with order counts
// @route   GET /api/admin/customers
// @access  Private/Admin
const getCustomers = async (req, res) => {
  try {
    // Only return users with role = "customer"
    // Explicitly exclude password
    const customers = await User.find({ role: 'customer' })
      .select('-password')
      .sort({ createdAt: -1 });

    // Add order counts to each customer
    const customersWithOrderCount = await Promise.all(customers.map(async (customer) => {
      const orderCount = await Order.countDocuments({ user: customer._id });
      return {
        _id: customer._id,
        name: customer.name,
        email: customer.email,
        mobile: customer.mobile,
        profileImage: customer.profileImage,
        profilePhoto: customer.profileImage, // Providing both for compatibility
        address: customer.address,
        createdAt: customer.createdAt,
        role: customer.role,
        totalOrders: orderCount
      };
    }));

    res.status(200).json({
      success: true,
      count: customersWithOrderCount.length,
      customers: customersWithOrderCount
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single customer details
// @route   GET /api/admin/customers/:id
// @access  Private/Admin
const getCustomerById = async (req, res) => {
  try {
    const customer = await User.findById(req.params.id).select('-password');
    if (!customer) {
      return res.status(404).json({ success: false, message: 'Customer not found' });
    }

    const orderCount = await Order.countDocuments({ user: customer._id });

    res.status(200).json({
      success: true,
      customer: {
        _id: customer._id,
        name: customer.name,
        email: customer.email,
        mobile: customer.mobile,
        profileImage: customer.profileImage,
        profilePhoto: customer.profileImage,
        address: customer.address,
        createdAt: customer.createdAt,
        role: customer.role,
        totalOrders: orderCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get customer orders
// @route   GET /api/admin/customers/:id/orders
// @access  Private/Admin
const getCustomerOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.params.id }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: orders.length, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get customer measurements
// @route   GET /api/admin/customers/:id/measurements
// @access  Private/Admin
const getCustomerMeasurements = async (req, res) => {
  try {
    const measurements = await Measurement.find({ userId: req.params.id }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: measurements.length, measurements });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getDashboardStats,
  getCustomers,
  getCustomerById,
  getCustomerOrders,
  getCustomerMeasurements
};
