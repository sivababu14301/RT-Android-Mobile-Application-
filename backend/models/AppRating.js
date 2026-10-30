const mongoose = require('mongoose');

const appRatingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  name: {
    type: String,
    required: [true, 'Please provide user name'],
    default: 'Valued Customer'
  },
  email: {
    type: String,
    required: false,
    default: ''
  },
  rating: {
    type: Number,
    required: [true, 'Please provide a star rating'],
    min: 1,
    max: 5
  },
  feedback: {
    type: String,
    required: [true, 'Please enter feedback text'],
    trim: true
  }
}, {
  timestamps: true,
  collection: 'app_ratings'
});

module.exports = mongoose.model('AppRating', appRatingSchema);
