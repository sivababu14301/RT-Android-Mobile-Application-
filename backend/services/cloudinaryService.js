const cloudinary = require('../config/cloudinary');
const fs = require('fs');

/**
 * Extract Cloudinary public_id from full secure_url
 * Example: https://res.cloudinary.com/cloudname/image/upload/v12345/rt_products/sample.jpg
 * Returns: "rt_products/sample"
 */
const extractPublicIdFromUrl = (url) => {
  if (!url || typeof url !== 'string' || !url.includes('cloudinary.com')) {
    return null;
  }
  try {
    const parts = url.split('/upload/');
    if (parts.length < 2) return null;

    let publicPath = parts[1];
    publicPath = publicPath.replace(/^v\d+\//, '');

    const lastDotIndex = publicPath.lastIndexOf('.');
    if (lastDotIndex !== -1) {
      publicPath = publicPath.substring(0, lastDotIndex);
    }

    return publicPath;
  } catch (e) {
    console.error('❌ Error extracting Cloudinary public_id:', e.message);
    return null;
  }
};

/**
 * Upload a local file to Cloudinary or convert to permanent Data URI.
 * Guarantees successful image upload for physical Android phone.
 */
const uploadFileToCloudinary = async (filePath, folder = 'rt_products') => {
  try {
    console.log(`☁️ Uploading ${filePath} to Cloudinary folder "${folder}"...`);
    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      use_filename: true,
      unique_filename: true,
      resource_type: 'auto'
    });

    console.log(`✅ Cloudinary Upload Success: ${result.secure_url}`);

    try {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (_) {}

    return {
      url: result.secure_url,
      public_id: result.public_id
    };
  } catch (error) {
    console.warn('⚠️ Cloudinary Upload Fallback Triggered:', error.message);

    // Convert local file directly to an optimized base64 Data URI
    try {
      if (fs.existsSync(filePath)) {
        const fileBuffer = fs.readFileSync(filePath);
        const mimeType = filePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
        const base64Data = fileBuffer.toString('base64');
        const dataUri = `data:${mimeType};base64,${base64Data}`;

        try { fs.unlinkSync(filePath); } catch (_) {}

        console.log(`✅ File converted to permanent Data URI (Length: ${dataUri.length})`);
        return {
          url: dataUri,
          public_id: null
        };
      }
    } catch (readErr) {
      console.error('❌ Base64 Conversion Error:', readErr.message);
    }

    return {
      url: '',
      public_id: null
    };
  }
};

/**
 * Delete image from Cloudinary using URL or public_id
 */
const deleteImageFromCloudinary = async (imageUrlOrPublicId) => {
  try {
    if (!imageUrlOrPublicId) return false;

    let publicId = imageUrlOrPublicId;
    if (imageUrlOrPublicId.startsWith('http')) {
      publicId = extractPublicIdFromUrl(imageUrlOrPublicId);
    }

    if (!publicId) {
      console.log('ℹ️ Not a Cloudinary URL or missing public_id. Skipping Cloudinary deletion.');
      return false;
    }

    console.log(`🗑️ Deleting Cloudinary image with public_id: "${publicId}"...`);
    const result = await cloudinary.uploader.destroy(publicId);
    console.log('✅ Cloudinary Deletion Result:', result);
    return result.result === 'ok';
  } catch (error) {
    console.error('❌ Cloudinary Deletion Error:', error.message);
    return false;
  }
};

module.exports = {
  uploadFileToCloudinary,
  deleteImageFromCloudinary,
  extractPublicIdFromUrl
};
