// Script to create initial admin user in Firestore
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createAdminUser() {
  try {
    const adminUser = {
      user_id: 'admin',
      password_hash: '7676aaafb027c825bd9abab78b234070e702752f625b752e55e55b48e607e358',
      role: 'admin_user',
      phc_name: 'Admin Office',
      email: 'sivachandran4code@gmail.com',
      phone_number: '9894585495',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      is_active: true
    };

    await db.collection('users').doc('admin').set(adminUser);
    
    console.log('✅ Admin user created successfully!');
    console.log('');
    console.log('Login credentials:');
    console.log('  User ID: admin');
    console.log('  Password: admin@123');
    console.log('  Email: sivachandran4code@gmail.com');
    console.log('  Phone: 9894585495');
    console.log('');
    console.log('You can now login at: https://tb-tracker-287ee.web.app');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    process.exit(1);
  }
}

createAdminUser();
