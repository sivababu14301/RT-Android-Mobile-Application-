const dns = require('dns');
try { dns.setServers(['8.8.8.8', '1.1.1.1']); } catch (_) {}
const mongoose = require('mongoose');

const mongoUri = process.env.MONGO_URI || 'mongodb+srv://sivababu1122006_db_user:siva9585@cluster0.nd58sjz.mongodb.net/raymaans_tailors?retryWrites=true&w=majority';

const broken404Patterns = [
  'photo-1621072156002-e2fcced0b170',
  'photo-1542272604-780c36856842'
];

const verifiedCategoryImages = {
  shirt: 'https://images.pexels.com/photos/297933/pexels-photo-297933.jpeg?auto=compress&cs=tinysrgb&w=800',
  pant: 'https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?auto=compress&cs=tinysrgb&w=800',
  tshirt: 'https://images.pexels.com/photos/428340/pexels-photo-428340.jpeg?auto=compress&cs=tinysrgb&w=800',
  suit: 'https://images.pexels.com/photos/1342609/pexels-photo-1342609.jpeg?auto=compress&cs=tinysrgb&w=800',
  wedding: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=1000&auto=format&fit=crop',
  default: 'https://images.pexels.com/photos/297933/pexels-photo-297933.jpeg?auto=compress&cs=tinysrgb&w=800'
};

function getVerifiedImageForProduct(name, category) {
  const cleanCat = (category || '').toLowerCase();
  const cleanName = (name || '').toLowerCase();

  if (cleanCat.includes('wedding') || cleanName.includes('sherwani')) {
    return verifiedCategoryImages.wedding;
  }
  if (cleanCat.includes('t-shirt') || cleanCat.includes('tshirt') || cleanName.includes('t shirt')) {
    return verifiedCategoryImages.tshirt;
  }
  if (cleanCat.includes('pant') || cleanCat.includes('paint') || cleanName.includes('pant') || cleanName.includes('jean')) {
    return verifiedCategoryImages.pant;
  }
  if (cleanCat.includes('suit')) {
    return verifiedCategoryImages.suit;
  }
  if (cleanCat.includes('shirt') || cleanName.includes('shirt')) {
    return verifiedCategoryImages.shirt;
  }
  return verifiedCategoryImages.default;
}

async function purgeBrokenUrls() {
  try {
    await mongoose.connect(mongoUri, { dbName: 'raymaans_tailors' });
    const Product = mongoose.connection.db.collection('products');
    const products = await Product.find({}).toArray();

    console.log(`🔍 Inspecting ${products.length} products for broken 404 URL pattern...`);
    let purgedCount = 0;

    for (const p of products) {
      if (p.images && p.images.some(img => typeof img === 'string' && broken404Patterns.some(pat => img.includes(pat)))) {
        const filtered = p.images.filter(img => typeof img === 'string' && !broken404Patterns.some(pat => img.includes(pat)));
        if (filtered.length === 0) {
          filtered.push(getVerifiedImageForProduct(p.name, p.category));
        }
        await Product.updateOne({ _id: p._id }, { $set: { images: filtered } });
        purgedCount++;
        console.log(`✅ Purged broken 404 URL from "${p.name}" (${p._id}):`, filtered);
      }
    }

    console.log(`🎉 Purge Completed! Cleaned ${purgedCount} products.`);
    await mongoose.disconnect();
  } catch (err) {
    console.error('❌ Error purging URLs:', err);
  }
}

purgeBrokenUrls();
