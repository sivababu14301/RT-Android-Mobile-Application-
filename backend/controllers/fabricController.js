const Fabric = require('../models/Fabric');
const Product = require('../models/Product');

// Seed default fabrics if collection is empty
const seedDefaultFabrics = async () => {
  try {
    const count = await Fabric.countDocuments();
    if (count === 0) {
      const defaultFabrics = [
        { name: 'Cotton', isActive: true },
        { name: 'Linen', isActive: true },
        { name: 'Silk', isActive: true },
        { name: 'Denim', isActive: true },
        { name: 'Polyester', isActive: true },
      ];
      await Fabric.insertMany(defaultFabrics);
      console.log('✅ Default fabrics seeded successfully');
    }
  } catch (error) {
    console.error('❌ Error seeding default fabrics:', error.message);
  }
};

// @desc    Get active fabrics (User facing)
// @route   GET /api/fabrics
// @access  Public
const getActiveFabrics = async (req, res) => {
  try {
    await seedDefaultFabrics();
    const fabrics = await Fabric.find({ isActive: true }).sort({ name: 1 });
    res.status(200).json({
      success: true,
      count: fabrics.length,
      fabrics,
    });
  } catch (error) {
    console.error('❌ Get Active Fabrics Error:', error.message);
    res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
  }
};

// @desc    Get all fabrics (Admin facing)
// @route   GET /api/admin/fabrics
// @access  Private/Admin
const getAllFabrics = async (req, res) => {
  try {
    await seedDefaultFabrics();
    const fabrics = await Fabric.find().sort({ createdAt: -1 });
    res.status(200).json({
      success: true,
      count: fabrics.length,
      fabrics,
    });
  } catch (error) {
    console.error('❌ Get All Fabrics Error:', error.message);
    res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
  }
};

// @desc    Create new fabric (Admin facing)
// @route   POST /api/admin/fabrics
// @access  Private/Admin
const createFabric = async (req, res) => {
  try {
    const { name, isActive } = req.body;
    if (!name || !name.trim()) {
      return res.status(400).json({ success: false, message: 'Please provide a fabric name' });
    }

    const trimmedName = name.trim();
    const existingFabric = await Fabric.findOne({
      name: { $regex: new RegExp(`^${trimmedName}$`, 'i') }
    });

    if (existingFabric) {
      return res.status(400).json({ success: false, message: 'Fabric already exists' });
    }

    const fabric = await Fabric.create({
      name: trimmedName,
      isActive: isActive !== undefined ? isActive : true,
    });

    res.status(201).json({
      success: true,
      message: 'Fabric created successfully',
      fabric,
    });
  } catch (error) {
    console.error('❌ Create Fabric Error:', error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update fabric (Admin facing)
// @route   PUT /api/admin/fabrics/:id
// @access  Private/Admin
const updateFabric = async (req, res) => {
  try {
    const fabric = await Fabric.findById(req.params.id);
    if (!fabric) {
      return res.status(404).json({ success: false, message: 'Fabric not found' });
    }

    const { name, isActive } = req.body;

    if (name && name.trim()) {
      const trimmedName = name.trim();
      if (trimmedName.toLowerCase() !== fabric.name.toLowerCase()) {
        const existingFabric = await Fabric.findOne({
          name: { $regex: new RegExp(`^${trimmedName}$`, 'i') }
        });
        if (existingFabric) {
          return res.status(400).json({ success: false, message: 'Fabric name already exists' });
        }
      }
      fabric.name = trimmedName;
    }

    if (isActive !== undefined) {
      fabric.isActive = isActive;
    }

    const updatedFabric = await fabric.save();

    res.status(200).json({
      success: true,
      message: 'Fabric updated successfully',
      fabric: updatedFabric,
    });
  } catch (error) {
    console.error('❌ Update Fabric Error:', error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete fabric (Admin facing)
// @route   DELETE /api/admin/fabrics/:id
// @access  Private/Admin
const deleteFabric = async (req, res) => {
  try {
    const fabric = await Fabric.findById(req.params.id);
    if (!fabric) {
      return res.status(404).json({ success: false, message: 'Fabric not found' });
    }

    // Check if any product is using this fabric
    const productCount = await Product.countDocuments({
      fabric: { $regex: new RegExp(`^${fabric.name}$`, 'i') }
    });

    if (productCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete '${fabric.name}' because it is currently used by ${productCount} product(s). You can disable it instead.`
      });
    }

    await fabric.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Fabric deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete Fabric Error:', error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  seedDefaultFabrics,
  getActiveFabrics,
  getAllFabrics,
  createFabric,
  updateFabric,
  deleteFabric,
};
