const { initializeApp } = require('firebase/app');
const { getFirestore, doc, setDoc, serverTimestamp } = require('firebase/firestore');

// Firebase config
const firebaseConfig = {
  apiKey: 'AIzaSyBCIRvh4tLZph55ULwuk1pAfNWH7sUIE3g',
  authDomain: 'tb-tracker-287ee.firebaseapp.com',
  projectId: 'tb-tracker-287ee',
  storageBucket: 'tb-tracker-287ee.firebasestorage.app',
  messagingSenderId: '1081918870422',
  appId: '1:1081918870422:web:747c98abd24b1bde1983b7'
};

async function createAdmin() {
  try {
    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    
    const adminData = {
      user_id: 'admin',
      password_hash: '7676aaafb027c825bd9abab78b234070e702752f625b752e55e55b48e607e358',
      role: 'admin_user',
      phc_name: 'Admin Office',
      email: 'sivachandran4code@gmail.com',
      phone_number: '9894585495',
      created_at: serverTimestamp(),
      is_active: true
    };
    
    await setDoc(doc(db, 'users', 'admin'), adminData);
    console.log('✅ Admin user created successfully!');
    console.log('Login with: admin / admin@123');
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

createAdmin();