const mongoose = require('mongoose');
const dns = require('dns');

// Configure DNS for MongoDB Atlas SRV record resolution
try {
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (_) {}

const connectDB = async () => {
  try {
    console.log('🔄 MongoDB connection started...');
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      dbName: 'raymaans_tailors',
    });
    console.log('✅ MongoDB Atlas Connected Successfully');
  } catch (error) {
    console.error(`❌ MongoDB Atlas connection failed: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
