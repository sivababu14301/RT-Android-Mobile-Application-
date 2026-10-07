const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
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

// Ensure destination uploads directory exists
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer Configuration for Product & Review Images
const storage = multer.diskStorage({
  destination(req, file, cb) {
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename(req, file, cb) {
    const safeName = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
    cb(null, `img-${Date.now()}-${safeName}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit per image
});

// Safe Multer upload middleware wrapper
const safeUploadMiddleware = (req, res, next) => {
  upload.array('images', 10)(req, res, (err) => {
    if (err) {
      console.error('❌ MULTER UPLOAD ERROR:', err);
      return res.status(400).json({
        success: false,
        message: err.message || 'Image upload failed'
      });
    }
    next();
  });
};

// IMPORTANT: ALL ROUTES HERE ARE PREFIXED WITH /api/products in server.js

// Public routes
router.get('/', getProducts);
router.get('/:id', getProductById);

// Authenticated image upload for Product / Review images
router.post('/upload', protect, safeUploadMiddleware, uploadProductImages);

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
