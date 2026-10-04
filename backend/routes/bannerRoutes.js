const express = require('express');
const router = express.Router();
const { addBanner, getBanners, updateBanner, deleteBanner } = require('../controllers/bannerController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', getBanners);
router.post('/', protect, admin, addBanner);
router.put('/:id', protect, admin, updateBanner);
router.delete('/:id', protect, admin, deleteBanner);

module.exports = router;
