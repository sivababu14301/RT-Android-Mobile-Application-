const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

// @desc    Register user
// @route   POST /api/auth/register
const registerUser = async (req, res) => {
  console.log("--- REGISTER ATTEMPT ---");
  const name = req.body.name || req.body.fullName;
  const { email, mobile, password, rememberAccess } = req.body;

  if (!name || !email || !mobile || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please fill all required fields: Name, Email, Mobile Number and Password'
    });
  }

  try {
    const trimmedEmail = email.trim().toLowerCase();
    const trimmedMobile = mobile.trim();

    // Check if email already exists
    const existingEmail = await User.findOne({ email: trimmedEmail });
    if (existingEmail) {
      return res.status(400).json({
        success: false,
        message: 'Email address is already registered.'
      });
    }

    // Check if mobile already exists
    const existingMobile = await User.findOne({ mobile: trimmedMobile });
    if (existingMobile) {
      return res.status(400).json({
        success: false,
        message: 'Mobile number is already registered.'
      });
    }

    const userAccessKey = rememberAccess ? rememberAccess.trim() : trimmedEmail;

    const user = await User.create({
      name: name.trim(),
      email: trimmedEmail,
      mobile: trimmedMobile,
      password,
      rememberAccess: userAccessKey,
      role: 'customer'
    });

    return res.status(201).json({
      success: true,
      message: 'Registration successful',
      user: {
        _id: user.id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
        role: user.role
      }
    });

  } catch (error) {
    console.error('❌ Registration Error:', error.message || error);
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'Email or Mobile already exists.' });
    }
    return res.status(400).json({ success: false, message: error.message || 'Registration failed' });
  }
};

// @desc    Authenticate a user
// @route   POST /api/auth/login
const loginUser = async (req, res) => {
  console.log("LOGIN ROUTE HIT");
  const { email, password } = req.body;

  const loginEmail = email ? email.trim().toLowerCase() : '';
  console.log("LOGIN EMAIL:", loginEmail);

  if (!loginEmail || !password) {
    return res.status(400).json({ success: false, message: 'Please provide email and password' });
  }

  try {
    const user = await User.findOne({ email: loginEmail }).select('+password');
    console.log("USER FOUND:", !!user);

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const isMatch = await user.matchPassword(password);
    console.log("PASSWORD MATCH:", isMatch);

    if (isMatch) {
      const token = generateToken(user._id);
      return res.status(200).json({
        success: true,
        token: token,
        role: user.role,
        user: {
          _id: user.id,
          name: user.name,
          email: user.email,
          mobile: user.mobile,
          role: user.role,
          profileImage: user.profileImage
        }
      });
    } else {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
  } catch (error) {
    console.error("❌ LOGIN ERROR:", error);
    return res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
  }
};

// @desc    Check if email exists for forgot password
// @route   POST /api/auth/forgot-password
const forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found with this email' });
    }
    res.status(200).json({ success: true, message: 'Email verified' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Verify remember access key
// @route   POST /api/auth/verify-remember-access
const verifyRememberAccess = async (req, res) => {
  const { email, rememberAccess } = req.body;
  try {
    const user = await User.findOne({ email: email.trim().toLowerCase() }).select('+rememberAccess');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const isMatch = await user.matchRememberAccess(rememberAccess);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid Remember Access Key' });
    }

    res.status(200).json({ success: true, message: 'Key verified' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Reset password
// @route   POST /api/auth/reset-password
const resetPassword = async (req, res) => {
  const { email, rememberAccess, newPassword, password } = req.body;
  const passToSet = newPassword || password;

  if (!email || !passToSet) {
    return res.status(400).json({ success: false, message: 'Please provide email and new password' });
  }

  try {
    const user = await User.findOne({ email: email.trim().toLowerCase() }).select('+rememberAccess');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (rememberAccess && user.rememberAccess) {
      const isMatch = await user.matchRememberAccess(rememberAccess);
      if (!isMatch) {
        return res.status(401).json({ success: false, message: 'Invalid Remember Access Key' });
      }
    }

    user.password = passToSet;
    await user.save();

    res.status(200).json({ success: true, message: 'Password reset successful' });
  } catch (error) {
    console.error('❌ Reset Password Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { registerUser, loginUser, forgotPassword, verifyRememberAccess, resetPassword };
