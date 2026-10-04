const Category = require('../models/Category');
const mongoose = require('mongoose');

// @desc    Add a new category
// @route   POST /api/categories
// @access  Private/Admin
const addCategory = async (req, res) => {
  try {
    console.log("POST /api/categories");
    console.log("BODY:", req.body);
    console.log("USER:", req.user);

    const { name, description, image, isActive } = req.body;

    if (!name || !description) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name and description'
      });
    }

    // Check if category exists
    const categoryExists = await Category.findOne({ name: { $regex: new RegExp(`^${name}$`, 'i') } });
    if (categoryExists) {
      return res.status(400).json({
        success: false,
        message: 'Category already exists'
      });
    }

    const category = new Category({
      name,
      description,
      image,
      isActive
    });

    const savedCategory = await category.save();

    console.log("-------------------------------");
    console.log("✅ DATABASE INSERTION SUCCESS");
    console.log("DATABASE NAME:", mongoose.connection.name);
    console.log("COLLECTION:", savedCategory.constructor.collection.name);
    console.log("CATEGORY CREATED:", savedCategory);
    console.log("-------------------------------");

    res.status(201).json({
      success: true,
      message: 'Category added successfully',
      category: savedCategory
    });
  } catch (error) {
    console.error("ADD CATEGORY ERROR:", error);
    res.status(500).json({
      success: false,
      message: 'Category creation failed',
      error: error.message
    });
  }
};

// @desc    Get all categories
// @route   GET /api/categories
// @access  Public
const getCategories = async (req, res) => {
  try {
    // Return all categories for admin/management, or filter for public
    const categories = await Category.find();

    console.log("CATEGORIES FETCHED:", categories.length);

    res.status(200).json({
      success: true,
      count: categories.length,
      categories
    });
  } catch (error) {
    console.error("GET CATEGORIES ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single category
// @route   GET /api/categories/:id
// @access  Public
const getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (category) {
      res.status(200).json({ success: true, category });
    } else {
      res.status(404).json({ success: false, message: 'Category not found' });
    }
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid category ID' });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update category
// @route   PUT /api/categories/:id
// @access  Private/Admin
const updateCategory = async (req, res) => {
  try {
    const { name, description, image, isActive } = req.body;

    const category = await Category.findById(req.params.id);

    if (category) {
      category.name = name || category.name;
      category.description = description || category.description;
      category.image = image || category.image;
      category.isActive = isActive !== undefined ? isActive : category.isActive;

      const updatedCategory = await category.save();
      res.status(200).json({
        success: true,
        message: 'Category updated successfully',
        category: updatedCategory
      });
    } else {
      res.status(404).json({ success: false, message: 'Category not found' });
    }
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid category ID' });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete category
// @route   DELETE /api/categories/:id
// @access  Private/Admin
const deleteCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (category) {
      await Category.findByIdAndDelete(req.params.id);
      res.status(200).json({ success: true, message: 'Category deleted successfully' });
    } else {
      res.status(404).json({ success: false, message: 'Category not found' });
    }
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid category ID' });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Upload category image
// @route   POST /api/categories/upload
// @access  Private/Admin
const uploadCategoryImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload an image' });
    }

    const filePath = `/uploads/${req.file.filename}`;

    res.status(200).json({
      success: true,
      message: 'Image uploaded successfully',
      imageUrl: filePath
    });
  } catch (error) {
    console.error('❌ UPLOAD CATEGORY IMAGE ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addCategory,
  getCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
  uploadCategoryImage
};
