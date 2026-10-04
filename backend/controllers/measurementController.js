const Measurement = require('../models/Measurement');

// @desc    Create new measurement
// @route   POST /api/measurements
// @access  Private
const createMeasurement = async (req, res) => {
  try {
    const { type, chest, waist, shoulder, sleeveLength, shirtLength, neck, pantWaist, hip, thigh, inseam, pantLength, customMeasurements } = req.body;

    console.log("-------------------------------");
    console.log("CREATE MEASUREMENT BODY:", req.body);
    console.log("CREATE MEASUREMENT USER:", req.user._id);

    if (!type) {
      return res.status(400).json({ success: false, message: 'Measurement type is required' });
    }

    const savedMeasurement = await Measurement.create({
      userId: req.user._id,
      type,
      chest,
      waist,
      shoulder,
      sleeveLength,
      shirtLength,
      neck,
      pantWaist,
      hip,
      thigh,
      inseam,
      pantLength,
      customMeasurements
    });

    console.log("SAVED MEASUREMENT:", savedMeasurement);
    console.log("-------------------------------");

    res.status(201).json({
      success: true,
      message: 'Measurement saved successfully',
      measurement: savedMeasurement
    });
  } catch (error) {
    console.error("❌ CREATE MEASUREMENT ERROR:", error);
    res.status(400).json({
      success: false,
      message: 'Measurement creation failed',
      error: error.message
    });
  }
};

// @desc    Get logged in user's measurements
// @route   GET /api/measurements
// @access  Private
const getMyMeasurements = async (req, res) => {
  try {
    console.log("GET MEASUREMENTS USER:", req.user._id);

    const measurements = await Measurement.find({
      userId: req.user._id
    }).sort({ createdAt: -1 });

    console.log("MEASUREMENTS FOUND:", measurements);

    res.status(200).json({
      success: true,
      measurements: measurements
    });
  } catch (error) {
    console.error("❌ GET MY MEASUREMENTS ERROR:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single measurement
// @route   GET /api/measurements/:id
// @access  Private
const getMeasurementById = async (req, res) => {
  try {
    const measurement = await Measurement.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!measurement) {
      return res.status(404).json({ success: false, message: 'Measurement not found' });
    }

    res.status(200).json({ success: true, measurement: measurement });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update measurement
// @route   PUT /api/measurements/:id
// @access  Private
const updateMeasurement = async (req, res) => {
  try {
    console.log("UPDATE MEASUREMENT ID:", req.params.id);

    const updatedMeasurement = await Measurement.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user._id
      },
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!updatedMeasurement) {
      return res.status(404).json({ success: false, message: 'Measurement not found or unauthorized' });
    }

    console.log("UPDATED MEASUREMENT:", updatedMeasurement);

    res.status(200).json({
      success: true,
      message: 'Measurement updated successfully',
      measurement: updatedMeasurement
    });
  } catch (error) {
    console.error("❌ UPDATE MEASUREMENT ERROR:", error);
    res.status(400).json({ success: false, message: error.message });
  }
};

// @desc    Delete measurement
// @route   DELETE /api/measurements/:id
// @access  Private
const deleteMeasurement = async (req, res) => {
  try {
    const result = await Measurement.deleteOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({ success: false, message: 'Measurement not found or unauthorized' });
    }

    res.status(200).json({
      success: true,
      message: 'Measurement deleted successfully'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  createMeasurement,
  getMyMeasurements,
  getMeasurementById,
  updateMeasurement,
  deleteMeasurement
};
