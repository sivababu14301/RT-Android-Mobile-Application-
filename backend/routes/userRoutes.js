const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const {
  getUserProfile,
  updateUserProfile,
  changePassword,
  getUserAddress,
  updateAddress,
  deleteAddress,
  updateProfilePic,
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

// Multer Configuration for Profile Pictures
const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, 'uploads/');
  },
  filename(req, file, cb) {
    cb(null, `${req.user._id}-${Date.now()}${path.extname(file.originalname)}`);
  },
});

const upload = multer({ storage });

// Profile routes
router.route('/profile')
  .get(protect, getUserProfile)
  .put(protect, updateUserProfile);

router.put('/profile/pic', protect, upload.single('image'), updateProfilePic);

// Security routes
router.put('/change-password', protect, changePassword);

// Address routes
router.route('/address')
  .get(protect, getUserAddress)
  .put(protect, updateAddress)
  .delete(protect, deleteAddress);

module.exports = router;
