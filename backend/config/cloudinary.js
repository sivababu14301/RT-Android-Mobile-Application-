const cloudinary = require('cloudinary').v2;

// Configure Cloudinary with environment variables
if (process.env.CLOUDINARY_URL) {
  cloudinary.config({
    cloudinary_url: process.env.CLOUDINARY_URL,
    secure: true
  });
  console.log('✅ Cloudinary configured via CLOUDINARY_URL');
} else if (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET) {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
    secure: true
  });
  console.log(`✅ Cloudinary configured for cloud "${process.env.CLOUDINARY_CLOUD_NAME}"`);
} else {
  console.warn('⚠️ Cloudinary Notice: Environment variables (CLOUDINARY_CLOUD_NAME / CLOUDINARY_URL) not set yet.');
}

module.exports = cloudinary;
