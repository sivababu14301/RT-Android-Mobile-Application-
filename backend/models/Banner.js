const mongoose = require('mongoose');

const bannerSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  image: {
    type: String,
    required: true
  },
  link: {
    type: String,
    default: ''
  },
  category: {
    type: String,
    default: ''
  },
  categoryId: {
    type: String,
    default: ''
  },
  targetType: {
    type: String,
    default: 'category'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  order: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true,
  collection: 'banners'
});

module.exports = mongoose.model('Banner', bannerSchema);
