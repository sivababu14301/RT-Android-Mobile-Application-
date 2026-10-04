const Offer = require('../models/Offer');

// @desc    Add a new offer
// @route   POST /api/offers
// @access  Private/Admin
const addOffer = async (req, res) => {
  try {
    console.log("--- ADD OFFER ATTEMPT ---");
    const {
      title,
      description,
      discount,
      image,
      targetType,
      category,
      categoryId,
      productId,
      productIds,
      link,
      startDate,
      endDate,
      isActive
    } = req.body;

    const offer = new Offer({
      title,
      description,
      discount,
      image,
      targetType: targetType || 'category',
      category: category || link || '',
      categoryId: categoryId || category || link || '',
      productId: productId || '',
      productIds: Array.isArray(productIds) ? productIds : (productId ? [productId] : []),
      link: link || category || '',
      startDate,
      endDate,
      isActive: isActive !== undefined ? isActive : true
    });

    const savedOffer = await offer.save();
    res.status(201).json({ success: true, offer: savedOffer });
  } catch (error) {
    console.error('❌ ADD OFFER ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all offers
// @route   GET /api/offers
// @access  Public
const getOffers = async (req, res) => {
  try {
    const offers = await Offer.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: offers.length, offers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update offer
// @route   PUT /api/offers/:id
// @access  Private/Admin
const updateOffer = async (req, res) => {
  try {
    const offer = await Offer.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!offer) return res.status(404).json({ success: false, message: 'Offer not found' });
    res.status(200).json({ success: true, offer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete offer
// @route   DELETE /api/offers/:id
// @access  Private/Admin
const deleteOffer = async (req, res) => {
  try {
    const offer = await Offer.findByIdAndDelete(req.params.id);
    if (!offer) return res.status(404).json({ success: false, message: 'Offer not found' });
    res.status(200).json({ success: true, message: 'Offer deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  addOffer,
  getOffers,
  updateOffer,
  deleteOffer
};
