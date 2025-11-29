const { initializeApp } = require('firebase/app');
const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
const { getFirestore, doc, setDoc } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: 'AIzaSyBCIRvh4tLZph55ULwuk1pAfNWH7sUIE3g',
  authDomain: 'tb-tracker-287ee.firebaseapp.com',
  projectId: 'tb-tracker-287ee',
  storageBucket: 'tb-tracker-287ee.firebasestorage.app',
  messagingSenderId: '1081918870422',
  appId: '1:1081918870422:web:747c98abd24b1bde1983b7'
};

async function createAuthUser() {
  const app = initializeApp(firebaseConfig);
  const auth = getAuth(app);
  const db = getFirestore(app);
  
  try {
    // Create Firebase Auth user
    const userCredential = await createUserWithEmailAndPassword(auth, 'sivachandran4code@gmail.com', 'admin@123');
    const user = userCredential.user;
    
    // Create user document in Firestore
    await setDoc(doc(db, 'users', user.uid), {
      user_id: 'admin',
      role: 'admin_user',
      phc_name: 'Admin Office',
      email: 'sivachandran4code@gmail.com',
      phone_number: '9894585495',
      is_active: true,
      created_at: new Date()
    });
    
    console.log('✅ Firebase Auth user created!');
    console.log('Email: sivachandran4code@gmail.com');
    console.log('Password: admin@123');
    console.log('UID:', user.uid);
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

createAuthUser();