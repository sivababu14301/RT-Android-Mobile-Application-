const express = require('express');
const router = express.Router();
const {
  getAllFabrics,
  createFabric,
  updateFabric,
  deleteFabric,
} = require('../controllers/fabricController');
const { protect, admin } = require('../middleware/authMiddleware');

// All routes are admin protected
router.use(protect, admin);

// @route   GET /api/admin/fabrics
// @route   POST /api/admin/fabrics
router.route('/')
  .get(getAllFabrics)
  .post(createFabric);

// @route   PUT /api/admin/fabrics/:id
// @route   DELETE /api/admin/fabrics/:id
router.route('/:id')
  .put(updateFabric)
  .delete(deleteFabric);

module.exports = router;
