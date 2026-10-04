const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const {
  addCategory,
  getCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
  uploadCategoryImage
} = require('../controllers/categoryController');
const { protect, admin } = require('../middleware/authMiddleware');

// Multer Configuration for Category Icons
const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, path.join(__dirname, '../uploads/'));
  },
  filename(req, file, cb) {
    cb(null, `category-${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 } // 2MB limit for icons
});

// Public routes
router.get('/', getCategories);
router.get('/:id', getCategoryById);

// Admin only routes
router.post('/upload', protect, admin, upload.single('image'), uploadCategoryImage);
router.post('/', protect, admin, addCategory);
router.put('/:id', protect, admin, updateCategory);
router.delete('/:id', protect, admin, deleteCategory);

module.exports = router;
