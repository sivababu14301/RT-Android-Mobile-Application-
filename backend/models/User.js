const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const addressSchema = new mongoose.Schema({
  fullName: { type: String, default: '' },
  mobile: { type: String, default: '' },
  doorNumber: { type: String, default: '' },
  street: { type: String, default: '' },
  area: { type: String, default: '' },
  city: { type: String, default: '' },
  state: { type: String, default: '' },
  pincode: { type: String, default: '' },
}, { _id: false });

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a name'],
    trim: true
  },
  email: {
    type: String,
    required: [true, 'Please add an email'],
    unique: true,
    lowercase: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email'
    ]
  },
  mobile: {
    type: String,
    required: [true, 'Please add a mobile number'],
    unique: true
  },
  password: {
    type: String,
    required: [true, 'Please add a password'],
    minlength: 6,
    select: false
  },
  rememberAccess: {
    type: String,
    required: false,
    select: false
  },
  address: {
    type: addressSchema,
    default: () => ({})
  },
  role: {
    type: String,
    enum: ['customer', 'admin', 'user'],
    default: 'customer',
    lowercase: true
  },
  profileImage: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Encrypt password and rememberAccess using bcrypt
userSchema.pre('save', async function() {
  // Only proceed if password or rememberAccess is modified
  if (!this.isModified('password') && !this.isModified('rememberAccess')) {
    return;
  }

  const salt = await bcrypt.genSalt(10);

  if (this.isModified('password') && this.password) {
    this.password = await bcrypt.hash(this.password, salt);
  }

  if (this.isModified('rememberAccess') && this.rememberAccess) {
    this.rememberAccess = await bcrypt.hash(this.rememberAccess, salt);
  }
});

// Match user entered password to hashed password in database
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Match user entered remember access to hashed value in database
userSchema.methods.matchRememberAccess = async function(enteredKey) {
  return await bcrypt.compare(enteredKey, this.rememberAccess);
};

module.exports = mongoose.model('User', userSchema);
