const Banner = require('../models/Banner');

// @desc    Add a new banner
// @route   POST /api/banners
// @access  Private/Admin
exports.addBanner = async (req, res) => {
  try {
    const { title, image, link, category, categoryId, targetType, isActive, order } = req.body;

    const banner = new Banner({
      title,
      image,
      link: link || category || '',
      category: category || link || '',
      categoryId: categoryId || '',
      targetType: targetType || 'category',
      isActive,
      order
    });

    const savedBanner = await banner.save();
    res.status(201).json({ success: true, banner: savedBanner });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all banners
// @route   GET /api/banners
// @access  Public
exports.getBanners = async (req, res) => {
  try {
    const banners = await Banner.find().sort({ order: 1 });
    res.status(200).json({ success: true, count: banners.length, banners });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update banner
// @route   PUT /api/banners/:id
// @access  Private/Admin
exports.updateBanner = async (req, res) => {
  try {
    const banner = await Banner.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!banner) return res.status(404).json({ success: false, message: 'Banner not found' });
    res.status(200).json({ success: true, banner });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete banner
// @route   DELETE /api/banners/:id
// @access  Private/Admin
exports.deleteBanner = async (req, res) => {
  try {
    const banner = await Banner.findByIdAndDelete(req.params.id);
    if (!banner) return res.status(404).json({ success: false, message: 'Banner not found' });
    res.status(200).json({ success: true, message: 'Banner deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
