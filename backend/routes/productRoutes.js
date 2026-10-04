const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const {
  addProduct,
  getProducts,
  getProductById,
  updateProduct,
  updateStock,
  deleteProduct,
  uploadProductImages
} = require('../controllers/productController');
const {
  getProductReviews,
  createProductReview,
  updateProductReview,
  deleteProductReview
} = require('../controllers/reviewController');
const { protect, admin } = require('../middleware/authMiddleware');

// Multer Configuration for Product & Review Images
const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, path.join(__dirname, '../uploads/'));
  },
  filename(req, file, cb) {
    cb(null, `img-${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// IMPORTANT: ALL ROUTES HERE ARE PREFIXED WITH /api/products in server.js

// Public routes
router.get('/', getProducts);
router.get('/:id', getProductById);

// Authenticated image upload for Product / Review images
router.post('/upload', protect, upload.array('images', 10), uploadProductImages);

// Admin only routes
router.post('/', protect, admin, addProduct);
router.put('/:id', protect, admin, updateProduct);
router.put('/:id/stock', protect, admin, updateStock);
router.delete('/:id', protect, admin, deleteProduct);

// Review routes
router.get('/:productId/reviews', getProductReviews);
router.post('/:productId/reviews', protect, createProductReview);
router.put('/reviews/:id', protect, updateProductReview);
router.delete('/reviews/:id', protect, deleteProductReview);

module.exports = router;
