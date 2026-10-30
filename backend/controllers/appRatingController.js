const AppRating = require('../models/AppRating');
const { sendAppRatingEmail } = require('../services/emailService');

// @desc    Submit a new app rating & feedback
// @route   POST /api/app-ratings
// @access  Public / Optional Auth
const submitAppRating = async (req, res) => {
  try {
    const { rating, feedback, name, email } = req.body;

    const numRating = Number(rating);
    if (!numRating || isNaN(numRating) || numRating < 1 || numRating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Please select a valid star rating (1 to 5 stars).'
      });
    }

    if (!feedback || typeof feedback !== 'string' || feedback.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Please enter your feedback comments.'
      });
    }

    const userName = (name && name.trim().length > 0)
      ? name.trim()
      : (req.user ? (req.user.name || req.user.fullName) : 'Valued Customer');

    const userEmail = (email && email.trim().length > 0)
      ? email.trim()
      : (req.user ? req.user.email : '');

    // Prevent duplicate submission with identical feedback from same user within last 1 hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const existingRecent = await AppRating.findOne({
      name: userName,
      feedback: feedback.trim(),
      createdAt: { $gte: oneHourAgo }
    });

    if (existingRecent) {
      return res.status(400).json({
        success: false,
        message: 'You have already submitted this feedback recently. Thank you!'
      });
    }

    // 1. Create rating record in MongoDB
    const appRating = new AppRating({
      user: req.user ? req.user._id : undefined,
      name: userName,
      email: userEmail,
      rating: numRating,
      feedback: feedback.trim()
    });

    const savedRating = await appRating.save();

    // 2. Dispatch notification email to shop owner (raymaanstailors@gmail.com)
    await sendAppRatingEmail({
      name: savedRating.name,
      email: savedRating.email,
      rating: savedRating.rating,
      feedback: savedRating.feedback,
      createdAt: savedRating.createdAt
    });

    return res.status(201).json({
      success: true,
      message: 'Thank you for rating RT – Raymaans Tailors! Your feedback has been sent to the shop owner.',
      rating: savedRating
    });
  } catch (error) {
    console.error('❌ SUBMIT APP RATING ERROR:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit app rating on server.'
    });
  }
};

// @desc    Get all app ratings for Admin
// @route   GET /api/app-ratings
// @access  Private/Admin
const getAppRatings = async (req, res) => {
  try {
    const ratings = await AppRating.find().sort({ createdAt: -1 });

    const totalRatings = ratings.length;
    const avgRating = totalRatings > 0
      ? (ratings.reduce((acc, r) => acc + r.rating, 0) / totalRatings).toFixed(1)
      : 0;

    return res.status(200).json({
      success: true,
      count: totalRatings,
      avgRating: Number(avgRating),
      ratings
    });
  } catch (error) {
    console.error('❌ GET APP RATINGS ERROR:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch app ratings history.'
    });
  }
};

module.exports = {
  submitAppRating,
  getAppRatings
};
