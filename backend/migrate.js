const dns = require('dns');
try { dns.setServers(['8.8.8.8', '1.1.1.1']); } catch (_) {}
const mongoose = require('mongoose');

const mongoUri = process.env.MONGO_URI || 'mongodb+srv://sivababu1122006_db_user:siva9585@cluster0.nd58sjz.mongodb.net/raymaans_tailors?retryWrites=true&w=majority';

const categoryFallbacks = {
  shirt: 'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=1000&auto=format&fit=crop',
  pant: 'https://images.unsplash.com/photo-1542272604-780c36856842?q=80&w=1000&auto=format&fit=crop',
  tshirt: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=1000&auto=format&fit=crop',
  suit: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=1000&auto=format&fit=crop',
  wedding: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=1000&auto=format&fit=crop',
  default: 'https://images.unsplash.com/photo-1621072156002-e2fcced0b170?q=80&w=1000&auto=format&fit=crop'
};

function getFallbackForCategory(catName) {
  const clean = (catName || '').toLowerCase();
  if (clean.includes('t-shirt') || clean.includes('tshirt')) return categoryFallbacks.tshirt;
  if (clean.includes('shirt')) return categoryFallbacks.shirt;
  if (clean.includes('pant') || clean.includes('jean') || clean.includes('trouser')) return categoryFallbacks.pant;
  if (clean.includes('suit')) return categoryFallbacks.suit;
  if (clean.includes('wedding')) return categoryFallbacks.wedding;
  return categoryFallbacks.default;
}

async function migrateLegacyImages() {
  try {
    await mongoose.connect(mongoUri, { dbName: 'raymaans_tailors' });
    const Product = mongoose.connection.db.collection('products');
    const products = await Product.find({}).toArray();

    console.log(`🔍 Checking ${products.length} products in MongoDB Atlas...`);
    let updatedCount = 0;

    for (const p of products) {
      let needsUpdate = false;
      const newImages = [];

      for (const img of (p.images || [])) {
        if (img && (img.startsWith('http://') || img.startsWith('https://'))) {
          // Keep valid Cloudinary or permanent HTTPS URLs
          newImages.push(img);
        } else if (img && (img.startsWith('/uploads/') || img.startsWith('uploads/'))) {
          // Replace lost Render ephemeral disk image with high quality permanent apparel image
          newImages.push(getFallbackForCategory(p.category));
          needsUpdate = true;
        } else {
          newImages.push(img);
        }
      }

      if (newImages.length === 0) {
        newImages.push(getFallbackForCategory(p.category));
        needsUpdate = true;
      }

      if (needsUpdate) {
        await Product.updateOne(
          { _id: p._id },
          { $set: { images: newImages } }
        );
        updatedCount++;
        console.log(`✅ Updated "${p.name}" (${p._id}):`, newImages);
      }
    }

    console.log(`🎉 Migration Completed! Successfully updated ${updatedCount} legacy products to permanent URLs.`);
    await mongoose.disconnect();
  } catch (err) {
    console.error('❌ Migration Error:', err);
  }
}

migrateLegacyImages();
