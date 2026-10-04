const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const mongoose = require('mongoose');
const connectDB = require('./config/db');
const User = require('./models/User');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

// Create Admin User if not exists
const createAdmin = async () => {
  try {
    const adminEmail = 'admin@raymaanstailors.com';
    let admin = await User.findOne({ email: adminEmail }).select('+password');
    if (!admin) {
      await User.create({
        name: 'Admin User',
        email: adminEmail,
        mobile: '0000000000',
        password: 'admin@123',
        rememberAccess: 'admin@123',
        role: 'admin'
      });
      console.log('✅ Default Admin User Initialized');
    } else {
      let isModified = false;
      if (admin.role !== 'admin') {
        admin.role = 'admin';
        isModified = true;
      }
      const isPasswordMatch = await admin.matchPassword('admin@123');
      if (!isPasswordMatch) {
        admin.password = 'admin@123';
        isModified = true;
      }
      if (isModified) {
        await admin.save();
        console.log('✅ Default Admin User Updated');
      }
    }
  } catch (error) {
    console.error('❌ Error initializing default admin:', error.message);
  }
};
createAdmin();

// Enable mongoose debug mode
mongoose.set('debug', true);

const app = express();

// Body parser
app.use(express.json());

// Enable CORS
app.use(cors());

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir);
}

// Static folder for uploads
app.use('/uploads', express.static(uploadDir));

// Test routes
app.get('/', (req, res) => {
  res.send('RT - Raymaans Tailors Backend Running...');
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Raymaans Tailors Backend is running'
  });
});

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const measurementRoutes = require('./routes/measurementRoutes');
const wishlistRoutes = require('./routes/wishlistRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const bannerRoutes = require('./routes/bannerRoutes');
const offerRoutes = require('./routes/offerRoutes');
const adminRoutes = require('./routes/adminRoutes');
const adminCustomerRoutes = require('./routes/adminCustomerRoutes');
const reportRoutes = require('./routes/reportRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const fabricRoutes = require('./routes/fabricRoutes');
const adminFabricRoutes = require('./routes/adminFabricRoutes');
const paymentRoutes = require('./routes/paymentRoutes');

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/fabrics', fabricRoutes);
app.use('/api/measurements', measurementRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/offers', offerRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/payment', paymentRoutes);

// Admin Routes (Specific sub-routes mounted before general /api/admin)
app.use('/api/admin/fabrics', adminFabricRoutes);
app.use('/api/admin/customers', adminCustomerRoutes);
app.use('/api/admin/reports', reportRoutes);
app.use('/api/admin/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);

// Catch-all route for debugging 404s
app.use((req, res) => {
  console.log(`❌ 404 - NOT FOUND: ${req.method} ${req.originalUrl}`);
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found on this server`
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT} (0.0.0.0)`);
  console.log(`💳 Payment endpoints ready at POST /api/payment/razorpay/order`);
});
