const dns = require('dns');
try { dns.setServers(['8.8.8.8', '1.1.1.1']); } catch (_) {}
const mongoose = require('mongoose');

const mongoUri = process.env.MONGO_URI || 'mongodb+srv://sivababu1122006_db_user:siva9585@cluster0.nd58sjz.mongodb.net/raymaans_tailors?retryWrites=true&w=majority';

async function cleanupAndNormalizeCategories() {
  await mongoose.connect(mongoUri, { dbName: 'raymaans_tailors' });
  const Category = mongoose.connection.db.collection('categories');
  const Product = mongoose.connection.db.collection('products');

  console.log('--- STARTING CATEGORY NORMALIZATION & DATABASE CLEANUP ---');

  const standardCategories = [
    { name: 'Pants', description: 'Custom tailored pants, trousers and jeans', image: '', isActive: true },
    { name: 'Shirts', description: 'Custom tailored casual and everyday shirts', image: '', isActive: true },
    { name: 'T-Shirts', description: 'Premium fitted T-shirts and polo shirts', image: '', isActive: true },
    { name: 'Formal Shirts', description: 'Luxury formal dress shirts', image: '', isActive: true },
    { name: 'Suits', description: 'Bespoke tailored suits and blazers', image: '', isActive: true },
    { name: 'Wedding Wear', description: 'Royal wedding tuxedos and ethnic wear', image: '', isActive: true },
    { name: 'Uniforms', description: 'Custom corporate and school uniforms', image: '', isActive: true },
  ];

  const products = await Product.find({}).toArray();
  for (let p of products) {
    const rawCat = (p.category || '').toString().trim().toLowerCase();
    let normalized = 'Shirts';

    if (rawCat.includes('t-shirt') || rawCat.includes('tshirt') || rawCat.includes('t shirt')) {
      normalized = 'T-Shirts';
    } else if (rawCat.includes('formal shirt')) {
      normalized = 'Formal Shirts';
    } else if (rawCat.includes('shirt')) {
      normalized = 'Shirts';
    } else if (rawCat.includes('paint') || rawCat.includes('pant') || rawCat.includes('trouser') || rawCat.includes('jean')) {
      normalized = 'Pants';
    } else if (rawCat.includes('suit')) {
      normalized = 'Suits';
    } else if (rawCat.includes('wedding')) {
      normalized = 'Wedding Wear';
    } else if (rawCat.includes('uniform')) {
      normalized = 'Uniforms';
    }

    await Product.updateOne({ _id: p._id }, { $set: { category: normalized } });
  }
  console.log('✅ Re-mapped product categories across', products.length, 'products.');

  await Category.deleteMany({});
  for (let cat of standardCategories) {
    await Category.insertOne(cat);
  }
  console.log('✅ Inserted', standardCategories.length, 'standard normalized categories.');

  const updatedCategories = await Category.find({}).toArray();
  console.log('\n--- UPDATED CATEGORIES COLLECTION ---');
  updatedCategories.forEach(c => console.log('•', c.name, '-', c.description));

  const updatedDistinctProducts = await Product.distinct('category');
  console.log('\n--- UPDATED DISTINCT PRODUCT CATEGORIES ---');
  console.log(updatedDistinctProducts);

  await mongoose.disconnect();
}

cleanupAndNormalizeCategories();
