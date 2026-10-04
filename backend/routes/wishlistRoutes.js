const express = require('express');
const router = express.Router();
const {
  addToWishlist,
  getWishlist,
  removeFromWishlist,
  checkWishlist
} = require('../controllers/wishlistController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/', getWishlist);
router.post('/:productId', addToWishlist);
router.delete('/:productId', removeFromWishlist);
router.get('/check/:productId', checkWishlist);

module.exports = router;
