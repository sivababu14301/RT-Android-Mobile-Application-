const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  orderItems: [
    {
      name: { type: String, required: true },
      quantity: { type: Number, required: true },
      image: { type: String, required: true },
      price: { type: Number, required: true },
      size: { type: String },
      color: { type: String },
      product: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true
      },
    }
  ],
  shippingAddress: {
    fullName: { type: String, required: true },
    mobile: { type: String, required: true },
    doorNumber: { type: String, required: true },
    street: { type: String, required: true },
    area: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    pincode: { type: String, required: true },
  },
  paymentMethod: {
    type: String,
    required: true,
    enum: ['COD', 'Razorpay'],
    default: 'COD'
  },
  razorpayOrderId: {
    type: String
  },
  razorpayPaymentId: {
    type: String
  },
  razorpaySignature: {
    type: String
  },
  paymentResult: {
    id: { type: String },
    status: { type: String },
    update_time: { type: String },
    email_address: { type: String },
  },
  itemsPrice: {
    type: Number,
    required: true,
    default: 0.0
  },
  shippingPrice: {
    type: Number,
    required: true,
    default: 0.0
  },
  totalPrice: {
    type: Number,
    required: true,
    default: 0.0
  },
  isPaid: {
    type: Boolean,
    required: true,
    default: false
  },
  paidAt: {
    type: Date
  },
  isDelivered: {
    type: Boolean,
    required: true,
    default: false
  },
  deliveredAt: {
    type: Date
  },
  status: {
    type: String,
    required: true,
    enum: ['Order Placed', 'Pending', 'Order Confirmed', 'Confirmed', 'Stitching', 'Ready', 'Out for Delivery', 'Delivered', 'Cancelled'],
    default: 'Order Placed'
  },
  statusHistory: [
    {
      status: { type: String, required: true },
      date: { type: String, required: true },
      time: { type: String, required: true },
      updatedAt: { type: Date, default: Date.now }
    }
  ]
}, {
  timestamps: true,
  collection: 'orders'
});

module.exports = mongoose.model('Order', orderSchema);
