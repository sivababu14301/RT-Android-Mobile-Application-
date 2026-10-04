const User = require('../models/User');

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
        address: user.address,
        profileImage: user.profileImage,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Get Profile Error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
  console.log('--- UPDATE PROFILE REQUEST ---');
  console.log('USER ID:', req.user._id);
  console.log('BODY:', req.body);

  const { name, email, mobile } = req.body;

  // Validation
  if (!name || !email || !mobile) {
    return res.status(400).json({
      success: false,
      message: 'Name, email and mobile are required'
    });
  }

  try {
    // Check if email is already taken by another user
    const emailExists = await User.findOne({
      email: email.toLowerCase(),
      _id: { $ne: req.user._id }
    });

    if (emailExists) {
      return res.status(400).json({
        success: false,
        message: 'Email is already in use by another account'
      });
    }

    // Check if mobile is already taken by another user
    const mobileExists = await User.findOne({
      mobile,
      _id: { $ne: req.user._id }
    });

    if (mobileExists) {
      return res.status(400).json({
        success: false,
        message: 'Mobile number is already in use by another account'
      });
    }

    // Use findByIdAndUpdate to avoid triggering pre('save') hook unnecessarily
    // when we are not updating the password.
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      {
        name,
        email: email.toLowerCase(),
        mobile
      },
      { new: true, runValidators: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    console.log('✅ PROFILE UPDATED SUCCESSFULLY');

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        _id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        mobile: updatedUser.mobile,
        role: updatedUser.role,
        profileImage: updatedUser.profileImage
      }
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server failed to update profile'
    });
  }
};

// @desc    Change password
// @route   PUT /api/users/change-password
// @access  Private
const changePassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ success: false, message: 'Please provide current and new passwords' });
  }

  try {
    const user = await User.findById(req.user._id).select('+password');

    if (user && (await user.matchPassword(currentPassword))) {
      user.password = newPassword;
      await user.save();
      return res.status(200).json({ success: true, message: 'Password changed successfully' });
    } else {
      return res.status(401).json({ success: false, message: 'Invalid current password' });
    }
  } catch (error) {
    console.error('Change Password Error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get user address
// @route   GET /api/users/address
// @access  Private
const getUserAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      return res.status(200).json({ success: true, address: user.address });
    } else {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('Get Address Error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Add or Update address
// @route   PUT /api/users/address
// @access  Private
const updateAddress = async (req, res) => {
  const { fullName, mobile, doorNumber, street, area, city, state, pincode } = req.body;

  try {
    const user = await User.findById(req.user._id);

    if (user) {
      user.address = {
        fullName,
        mobile,
        doorNumber,
        street,
        area,
        city,
        state,
        pincode,
      };

      await user.save();
      return res.status(200).json({ success: true, message: 'Address updated successfully', address: user.address });
    } else {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('Update Address Error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete address
// @route   DELETE /api/users/address
// @access  Private
const deleteAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      user.address = {
        fullName: '',
        mobile: '',
        doorNumber: '',
        street: '',
        area: '',
        city: '',
        state: '',
        pincode: '',
      };
      await user.save();
      return res.status(200).json({ success: true, message: 'Address deleted successfully' });
    } else {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('Delete Address Error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update profile picture
// @route   PUT /api/users/profile/pic
// @access  Private
const updateProfilePic = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload an image' });
    }

    const filePath = `/uploads/${req.file.filename}`;

    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      { profileImage: filePath },
      { new: true }
    );

    if (updatedUser) {
      return res.status(200).json({
        success: true,
        message: 'Profile picture updated',
        profileImage: filePath,
      });
    } else {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('Update Profile Pic Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server failed to update profile picture'
    });
  }
};

module.exports = {
  getUserProfile,
  updateUserProfile,
  changePassword,
  getUserAddress,
  updateAddress,
  deleteAddress,
  updateProfilePic,
};
