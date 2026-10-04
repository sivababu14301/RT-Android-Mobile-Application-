const express = require('express');
const router = express.Router();
const { getActiveFabrics } = require('../controllers/fabricController');

// @route   GET /api/fabrics
// @access  Public
router.get('/', getActiveFabrics);

module.exports = router;
