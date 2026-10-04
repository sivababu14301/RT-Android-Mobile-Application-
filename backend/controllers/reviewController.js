const Review = require('../models/Review');
const Product = require('../models/Product');
const Order = require('../models/Order');

// Recalculate average rating & review count for a product
const updateProductRatingSummary = async (productId) => {
  const reviews = await Review.find({ product: productId });
  const reviewCount = reviews.length;
  const averageRating = reviewCount > 0
    ? (reviews.reduce((acc, item) => item.rating + acc, 0) / reviewCount).toFixed(1)
    : 0;

  await Product.findByIdAndUpdate(productId, {
    rating: Number(averageRating),
    reviewCount
  });
};

// @desc    Get reviews for a product
// @route   GET /api/products/:productId/reviews
// @access  Public
const getProductReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ product: req.params.productId }).sort({ createdAt: -1 });

    // Calculate star distribution
    const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    reviews.forEach(review => {
      distribution[review.rating] = (distribution[review.rating] || 0) + 1;
    });

    res.status(200).json({
      success: true,
      count: reviews.length,
      distribution,
      reviews
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create a new review
// @route   POST /api/products/:productId/reviews
// @access  Private
const createProductReview = async (req, res) => {
  try {
    const { rating, comment, images } = req.body;
    const productId = req.params.productId;

    // 1. Check if user already reviewed
    const alreadyReviewed = await Review.findOne({
      product: productId,
      user: req.user._id
    });

    if (alreadyReviewed) {
      return res.status(400).json({ success: false, message: 'You have already reviewed this product' });
    }

    // 2. Check if user purchased the product and order is delivered
    const hasPurchased = await Order.findOne({
      user: req.user._id,
      status: 'Delivered',
      'orderItems.product': productId
    });

    if (!hasPurchased) {
      return res.status(403).json({
        success: false,
        message: 'You can only review products you have purchased and received (Delivered status).'
      });
    }

    // 3. Create review with images
    const review = await Review.create({
      product: productId,
      user: req.user._id,
      name: req.user.name || req.user.fullName || 'Customer',
      rating: Number(rating),
      comment: comment || '',
      images: Array.isArray(images) ? images : []
    });

    // 4. Update product rating summary
    await updateProductRatingSummary(productId);

    res.status(201).json({ success: true, message: 'Review submitted successfully', review });
  } catch (error) {
    console.error('CREATE REVIEW ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update a review
// @route   PUT /api/products/reviews/:id
// @access  Private
const updateProductReview = async (req, res) => {
  try {
    const { rating, comment, images } = req.body;
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({ success: false, message: 'Review not found' });
    }

    if (review.user.toString() !== req.user._id.toString()) {
      return res.status(401).json({ success: false, message: 'Not authorized to edit this review' });
    }

    if (rating !== undefined) review.rating = Number(rating);
    if (comment !== undefined) review.comment = comment;
    if (images !== undefined && Array.isArray(images)) review.images = images;

    const updatedReview = await review.save();
    await updateProductRatingSummary(review.product);

    res.status(200).json({ success: true, message: 'Review updated successfully', review: updatedReview });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete a review
// @route   DELETE /api/products/reviews/:id
// @access  Private
const deleteProductReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({ success: false, message: 'Review not found' });
    }

    if (review.user.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(401).json({ success: false, message: 'Not authorized to delete this review' });
    }

    const productId = review.product;
    await Review.findByIdAndDelete(req.params.id);
    await updateProductRatingSummary(productId);

    res.status(200).json({ success: true, message: 'Review deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getProductReviews,
  createProductReview,
  updateProductReview,
  deleteProductReview
};
