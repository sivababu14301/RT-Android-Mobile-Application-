const express = require('express');
const router = express.Router();
const { submitAppRating, getAppRatings } = require('../controllers/appRatingController');
const { protect, admin, optionalAuth } = require('../middleware/authMiddleware');

router.post('/', optionalAuth, submitAppRating);
router.get('/', protect, admin, getAppRatings);

module.exports = router;
