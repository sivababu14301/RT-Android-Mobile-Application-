const cloudinary = require('cloudinary').v2;

// Configure Cloudinary using environment variables or production defaults
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
  // Default Cloudinary credentials for RT Raymaans Tailors
  cloudinary.config({
    cloud_name: 'dph38sgl1',
    api_key: '519213567784318',
    api_secret: 'Z7GvL4C2S6N04vM13c8E_d1-m3w',
    secure: true
  });
  console.log('✅ Cloudinary configured using default production credentials for "dph38sgl1"');
}

module.exports = cloudinary;
