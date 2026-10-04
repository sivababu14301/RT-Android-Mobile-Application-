const mongoose = require('mongoose');
const User = require('../models/User');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const createAdmin = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB to create admin account');

    const adminEmail = 'admin@raymaanstailors.com';
    const adminPassword = 'admin@123';
    const adminRole = 'admin';

    // Check if admin already exists
    let adminUser = await User.findOne({ email: adminEmail.toLowerCase() });

    if (adminUser) {
      console.log(`ℹ️ Admin user ${adminEmail} already exists. Updating role and password...`);
      adminUser.role = adminRole;
      adminUser.password = adminPassword; // Password will be hashed by the User model's pre-save hook
      await adminUser.save();
      console.log('✅ Admin user updated successfully.');
    } else {
      console.log(`ℹ️ Creating new admin user ${adminEmail}...`);
      adminUser = await User.create({
        name: 'Raymaans Admin',
        email: adminEmail.toLowerCase(),
        mobile: '9999999999', // Placeholder mobile
        password: adminPassword,
        role: adminRole
      });
      console.log('✅ Admin user created successfully.');
    }

    mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin:', error);
    process.exit(1);
  }
};

createAdmin();
