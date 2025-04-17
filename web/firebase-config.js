// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDKOYgRxdjE6SpVbvHVU43Epj1h8tBHcyI",
  authDomain: "raya-b7f0e.firebaseapp.com",
  projectId: "raya-b7f0e",
  storageBucket: "raya-b7f0e.firebasestorage.app",
  messagingSenderId: "706760995742",
  appId: "1:706760995742:web:cbdd3d86ba058ba7c51c8f",
  measurementId: "G-T9JND9P1YF"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);