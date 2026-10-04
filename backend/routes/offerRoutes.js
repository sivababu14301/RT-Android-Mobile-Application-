const express = require('express');
const router = express.Router();
const { addOffer, getOffers, updateOffer, deleteOffer } = require('../controllers/offerController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', getOffers);
router.post('/', protect, admin, addOffer);
router.put('/:id', protect, admin, updateOffer);
router.delete('/:id', protect, admin, deleteOffer);

module.exports = router;
