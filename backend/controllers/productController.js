const Product = require('../models/Product');
const mongoose = require('mongoose');

// @desc    Add a new product
// @route   POST /api/products
// @access  Private/Admin
const addProduct = async (req, res) => {
  try {
    const { name, description, category, price, discountPrice, images, fabric, sizes, colors, stock, isFeatured } = req.body;

    console.log("--- ADD PRODUCT ATTEMPT ---");
    console.log("Body:", req.body);

    if (!name || !description || !category || !price || !fabric || stock === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields (name, description, category, price, fabric, stock)'
      });
    }

    // Create product with mapped data
    const product = new Product({
      name,
      description,
      category,
      price,
      discountPrice,
      images: images || [],
      fabric,
      sizes: sizes || [],
      colors: colors || [],
      stock,
      isFeatured: isFeatured === true || isFeatured === 'true'
    });

    const savedProduct = await product.save();
    console.log('✅ PRODUCT CREATED:', savedProduct.name);

    res.status(201).json({
      success: true,
      message: 'Product added successfully',
      product: savedProduct
    });
  } catch (error) {
    console.error('❌ ADD PRODUCT ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all products
// @route   GET /api/products
// @access  Public
const getProducts = async (req, res) => {
  try {
    const { search, category, fabric, minPrice, maxPrice, size, color, sort, page = 1, limit = 10 } = req.query;
    const query = {};

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
        { fabric: { $regex: search, $options: 'i' } }
      ];
    }

    if (category && category !== 'All') query.category = category;
    if (fabric) query.fabric = fabric;
    if (size) query.sizes = size;
    if (color) query.colors = color;

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    const skip = (Number(page) - 1) * Number(limit);
    let result = Product.find(query);

    if (sort === 'priceLow') result = result.sort({ price: 1 });
    else if (sort === 'priceHigh') result = result.sort({ price: -1 });
    else if (sort === 'newest') result = result.sort({ createdAt: -1 });
    else if (sort === 'rating') result = result.sort({ rating: -1 });
    else result = result.sort({ createdAt: -1 });

    const products = await result.skip(skip).limit(Number(limit));
    const total = await Product.countDocuments(query);

    res.status(200).json({
      success: true,
      count: products.length,
      total,
      products
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single product
// @route   GET /api/products/:id
const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product) res.status(200).json({ success: true, product });
    else res.status(404).json({ success: false, message: 'Product not found' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update product
// @route   PUT /api/products/:id
const updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (product) {
      res.status(200).json({ success: true, message: 'Product updated successfully', product });
    } else {
      res.status(404).json({ success: false, message: 'Product not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update stock
// @route   PUT /api/products/:id/stock
const updateStock = async (req, res) => {
  try {
    const { stock } = req.body;
    const product = await Product.findById(req.params.id);
    if (product) {
      product.stock = stock;
      await product.save();
      res.status(200).json({ success: true, message: 'Stock updated successfully', product });
    } else {
      res.status(404).json({ success: false, message: 'Product not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete product
// @route   DELETE /api/products/:id
const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (product) {
      await Product.findByIdAndDelete(req.params.id);
      res.status(200).json({ success: true, message: 'Product deleted successfully' });
    } else {
      res.status(404).json({ success: false, message: 'Product not found' });
    }
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid product ID' });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Upload multiple product images
// @route   POST /api/products/upload
// @access  Private/Admin
const uploadProductImages = async (req, res) => {
  try {
    console.log("--- UPLOAD IMAGES ATTEMPT ---");
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'Please upload images' });
    }

    const filePaths = req.files.map(file => `/uploads/${file.filename}`);
    console.log("Uploaded Files:", filePaths);

    res.status(200).json({
      success: true,
      message: 'Images uploaded successfully',
      images: filePaths
    });
  } catch (error) {
    console.error('❌ UPLOAD IMAGES ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addProduct,
  getProducts,
  getProductById,
  updateProduct,
  updateStock,
  deleteProduct,
  uploadProductImages
};
