const Wishlist = require('../models/Wishlist');
const Product = require('../models/Product');

// @desc    Add product to wishlist
// @route   POST /api/wishlist/:productId
// @access  Private
const addToWishlist = async (req, res) => {
  try {
    const productId = req.params.productId;
    const userId = req.user._id;

    console.log("-------------------------------");
    console.log("WISHLIST ADD ATTEMPT");
    console.log("WISHLIST USER:", userId);
    console.log("WISHLIST PRODUCT:", productId);

    // Verify Product exists
    const product = await Product.findById(productId);
    if (!product) {
      console.log("❌ PRODUCT NOT FOUND");
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    let wishlist = await Wishlist.findOne({ userId });

    if (!wishlist) {
      console.log("ℹ️ CREATING NEW WISHLIST FOR USER");
      wishlist = new Wishlist({
        userId,
        products: []
      });
    }

    // Check if product already exists
    if (wishlist.products.some(id => id.toString() === productId)) {
      console.log("⚠️ PRODUCT ALREADY IN WISHLIST");
      return res.status(400).json({ success: false, message: "Product already in wishlist" });
    }

    wishlist.products.push(productId);
    await wishlist.save();

    console.log("✅ WISHLIST SAVED:", wishlist);
    console.log("-------------------------------");

    res.status(201).json({
      success: true,
      message: "Product added to wishlist",
      wishlist
    });
  } catch (error) {
    console.error("❌ WISHLIST ADD ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get my wishlist
// @route   GET /api/wishlist
// @access  Private
const getWishlist = async (req, res) => {
  try {
    const userId = req.user._id;
    console.log("GET WISHLIST USER:", userId);

    const wishlist = await Wishlist.findOne({ userId }).populate('products');

    if (!wishlist) {
      return res.status(200).json({
        success: true,
        wishlist: { products: [] }
      });
    }

    console.log("✅ WISHLIST FETCHED, PRODUCTS:", wishlist.products.length);

    res.status(200).json({
      success: true,
      wishlist
    });
  } catch (error) {
    console.error("❌ GET WISHLIST ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Remove product from wishlist
// @route   DELETE /api/wishlist/:productId
// @access  Private
const removeFromWishlist = async (req, res) => {
  try {
    const productId = req.params.productId;
    const userId = req.user._id;

    console.log("WISHLIST REMOVE ATTEMPT:", productId);

    let wishlist = await Wishlist.findOne({ userId });

    if (!wishlist) {
      return res.status(404).json({ success: false, message: "Wishlist not found" });
    }

    wishlist.products = wishlist.products.filter(
      (id) => id.toString() !== productId
    );

    await wishlist.save();
    console.log("✅ PRODUCT REMOVED FROM WISHLIST");

    res.status(200).json({
      success: true,
      message: "Product removed from wishlist",
      wishlist
    });
  } catch (error) {
    console.error("❌ WISHLIST REMOVE ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Check if product is in wishlist
// @route   GET /api/wishlist/check/:productId
// @access  Private
const checkWishlist = async (req, res) => {
  try {
    const productId = req.params.productId;
    const userId = req.user._id;

    const wishlist = await Wishlist.findOne({
      userId,
      products: productId
    });

    res.status(200).json({
      success: true,
      isInWishlist: !!wishlist
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addToWishlist,
  getWishlist,
  removeFromWishlist,
  checkWishlist
};
