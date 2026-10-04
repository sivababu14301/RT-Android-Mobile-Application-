const express = require('express');
const router = express.Router();
const {
  createMeasurement,
  getMyMeasurements,
  getMeasurementById,
  updateMeasurement,
  deleteMeasurement
} = require('../controllers/measurementController');
const { protect } = require('../middleware/authMiddleware');

console.log('Measurement routes initialized');

router.post('/', protect, (req, res, next) => {
  console.log('POST /api/measurements - ROUTE HIT');
  next();
}, createMeasurement);

router.get('/', protect, getMyMeasurements);
router.get('/:id', protect, getMeasurementById);
router.put('/:id', protect, updateMeasurement);
router.delete('/:id', protect, deleteMeasurement);

module.exports = router;
