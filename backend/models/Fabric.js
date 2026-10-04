const mongoose = require('mongoose');

const fabricSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a fabric name'],
    unique: true,
    trim: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  collection: 'fabrics'
});

module.exports = mongoose.model('Fabric', fabricSchema);
