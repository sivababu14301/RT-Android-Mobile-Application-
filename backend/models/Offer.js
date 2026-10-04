const mongoose = require('mongoose');

const offerSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  discount: {
    type: String, // Storing as string like "20% OFF" or "Starting ₹2999"
    required: true
  },
  image: {
    type: String,
    required: true
  },
  targetType: {
    type: String,
    enum: ['category', 'product', 'Category', 'Product'],
    default: 'category'
  },
  category: {
    type: String,
    default: ''
  },
  categoryId: {
    type: String,
    default: ''
  },
  productId: {
    type: String,
    default: ''
  },
  productIds: [{
    type: String
  }],
  link: {
    type: String,
    default: ''
  },
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  collection: 'offers'
});

module.exports = mongoose.model('Offer', offerSchema);
