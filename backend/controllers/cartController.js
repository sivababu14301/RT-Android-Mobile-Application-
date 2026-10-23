const Cart = require('../models/Cart');
const Product = require('../models/Product');

// @desc    Add product to cart
// @route   POST /api/cart
// @access  Private
const addToCart = async (req, res) => {
  try {
    const { productId, quantity, size, color } = req.body;
    const userId = req.user._id;

    console.log("-------------------------------");
    console.log("CART ADD ATTEMPT");
    console.log("CART USER:", userId);
    console.log("CART PRODUCT:", productId);
    console.log("CART QUANTITY:", quantity);
    console.log("CART SIZE/COLOR:", size, color);

    if (!productId) {
      return res.status(400).json({ success: false, message: "Product ID is required" });
    }

    // Verify Product exists and check stock
    const product = await Product.findById(productId);
    if (!product) {
      console.log("❌ PRODUCT NOT FOUND");
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    const requestedQty = quantity || 1;
    if (product.stock < requestedQty) {
      return res.status(400).json({
        success: false,
        message: product.stock <= 0
          ? `"${product.name}" is currently Out of Stock.`
          : `Only ${product.stock} items available in stock.`
      });
    }

    let cart = await Cart.findOne({ userId });

    if (!cart) {
      console.log("ℹ️ CREATING NEW CART FOR USER");
      cart = new Cart({
        userId,
        items: [{ productId, quantity: requestedQty, size: size || '', color: color || '' }]
      });
    } else {
      // Check if product with same size and color already exists in cart
      const itemIndex = cart.items.findIndex(item =>
        item.productId &&
        item.productId.toString() === productId &&
        (item.size || '') === (size || '') &&
        (item.color || '') === (color || '')
      );

      if (itemIndex > -1) {
        console.log("ℹ️ ITEM EXISTS, INCREASING QUANTITY");
        cart.items[itemIndex].quantity += requestedQty;
      } else {
        console.log("ℹ️ ADDING NEW ITEM VARIANT TO CART");
        cart.items.push({ productId, quantity: requestedQty, size: size || '', color: color || '' });
      }
    }

    await cart.save();

    // Populate and filter out any orphaned null items
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');
    if (populatedCart && populatedCart.items) {
      populatedCart.items = populatedCart.items.filter(item => item.productId != null);
    }

    res.status(201).json({
      success: true,
      message: "Product added to cart",
      cart: populatedCart
    });
  } catch (error) {
    console.error("❌ CART ADD ERROR:", error);
    res.status(500).json({ success: false, message: error.message || 'Failed to add item to cart' });
  }
};

// @desc    Get my cart
// @route   GET /api/cart
// @access  Private
const getCart = async (req, res) => {
  try {
    const userId = req.user._id;

    let cart = await Cart.findOne({ userId }).populate('items.productId');

    if (!cart) {
      cart = { items: [] };
    } else if (cart.items) {
      cart.items = cart.items.filter(item => item.productId != null);
    }

    res.status(200).json({
      success: true,
      cart
    });
  } catch (error) {
    console.error("❌ GET CART ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update cart item quantity
// @route   PUT /api/cart/:productId
// @access  Private
const updateCartItem = async (req, res) => {
  try {
    const productId = req.params.productId;
    const { quantity } = req.body;
    const userId = req.user._id;

    let cart = await Cart.findOne({ userId });

    if (!cart) {
      return res.status(404).json({ success: false, message: "Cart not found" });
    }

    const itemIndex = cart.items.findIndex(item => item.productId && item.productId.toString() === productId);

    if (itemIndex === -1) {
      return res.status(404).json({ success: false, message: "Product not found in cart" });
    }

    if (quantity > 0) {
      cart.items[itemIndex].quantity = quantity;
    } else {
      cart.items.splice(itemIndex, 1);
    }

    await cart.save();
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');
    if (populatedCart && populatedCart.items) {
      populatedCart.items = populatedCart.items.filter(item => item.productId != null);
    }

    res.status(200).json({
      success: true,
      message: "Cart updated",
      cart: populatedCart
    });
  } catch (error) {
    console.error("❌ CART UPDATE ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Remove product from cart
// @route   DELETE /api/cart/:productId
// @access  Private
const removeFromCart = async (req, res) => {
  try {
    const productId = req.params.productId;
    const userId = req.user._id;

    let cart = await Cart.findOne({ userId });

    if (!cart) {
      return res.status(404).json({ success: false, message: "Cart not found" });
    }

    cart.items = cart.items.filter(item => item.productId && item.productId.toString() !== productId);

    await cart.save();
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');
    if (populatedCart && populatedCart.items) {
      populatedCart.items = populatedCart.items.filter(item => item.productId != null);
    }

    res.status(200).json({
      success: true,
      message: "Product removed from cart",
      cart: populatedCart
    });
  } catch (error) {
    console.error("❌ CART REMOVE ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Clear cart
// @route   DELETE /api/cart
// @access  Private
const clearCart = async (req, res) => {
  try {
    const userId = req.user._id;

    let cart = await Cart.findOne({ userId });

    if (cart) {
      cart.items = [];
      await cart.save();
    }

    res.status(200).json({
      success: true,
      message: "Cart cleared"
    });
  } catch (error) {
    console.error("❌ CLEAR CART ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addToCart,
  getCart,
  updateCartItem,
  removeFromCart,
  clearCart
};
