const mongoose = require('mongoose');

const measurementSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['shirt', 'pant', 'custom'],
    required: true
  },
  chest: Number,
  waist: Number,
  shoulder: Number,
  sleeveLength: Number,
  shirtLength: Number,
  neck: Number,
  pantWaist: Number,
  hip: Number,
  thigh: Number,
  inseam: Number,
  pantLength: Number,
  customMeasurements: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true,
  collection: 'measurements'
});

module.exports = mongoose.model('Measurement', measurementSchema);
