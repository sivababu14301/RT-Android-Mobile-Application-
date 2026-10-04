const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a product name'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Please add a product description']
  },
  category: {
    type: String,
    required: [true, 'Please add a product category']
  },
  price: {
    type: Number,
    required: [true, 'Please add a product price'],
    min: [0, 'Price cannot be negative']
  },
  discountPrice: {
    type: Number,
    min: [0, 'Discount price cannot be negative']
  },
  images: {
    type: [String],
    default: []
  },
  fabric: {
    type: String,
    required: [true, 'Please add a product fabric']
  },
  fabrics: {
    type: [String],
    default: []
  },
  sizes: {
    type: [String],
    default: []
  },
  colors: {
    type: [String],
    default: []
  },
  stock: {
    type: Number,
    required: [true, 'Please add product stock count'],
    min: [0, 'Stock cannot be negative'],
    default: 0
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  allowCustomFit: {
    type: Boolean,
    default: false
  },
  rating: {
    type: Number,
    default: 0
  },
  reviewCount: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true,
  collection: 'products'
});

// Use async pre-save hook for better compatibility with Mongoose 8+
productSchema.pre('save', async function() {
  if (this.stock <= 0) {
    this.isAvailable = false;
  } else {
    this.isAvailable = true;
  }
});

module.exports = mongoose.model('Product', productSchema);
