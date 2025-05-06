# Galok Raya - Belatuk Raya Invitation App

A beautiful Flutter app for sending Raya invitations and collecting RSVPs.

## Features

- Elegant welcome screen with floating ketupat animations
- Detailed event information page
- RSVP form with Firebase integration
- Thank you page with calendar integration and location directions
- Admin dashboard for managing RSVPs and exporting data
- Real-time attendee tracking

## Technologies Used

- Flutter
- Firebase (Firestore, Analytics)
- Google Maps integration
- Calendar integration
- WhatsApp integration

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase account
- Editor (VS Code, Android Studio, etc.)

### Setup Instructions

1. Clone this repository
   ```
   git clone https://github.com/syahmiyem/raya.git
   cd raya
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Set up Firestore database
   - Configure Firebase for your app platforms (Web, Android, iOS)
   - Copy `web/firebase-config.template.js` to `web/firebase-config.js`
   - Replace the placeholder values in `firebase-config.js` with your actual Firebase config:
     ```js
     const firebaseConfig = {
       apiKey: "YOUR_API_KEY",
       authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       storageBucket: "YOUR_PROJECT_ID.appspot.com",
       messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
       appId: "YOUR_APP_ID",
       measurementId: "YOUR_MEASUREMENT_ID"
     };
     ```
   - For Android and iOS, follow the Firebase documentation to add the appropriate config files

4. Run the app
   ```
   flutter run
   ```

## Admin Access

To access the admin dashboard, tap the welcome screen 5 times. From there, you can:

- View all RSVPs and attendee statistics
- Download all RSVP data as a text file
- Delete individual RSVPs or all RSVPs (with confirmation)

## Project Structure

- `/lib/screens` - Main app screens
- `/lib/widgets` - Reusable UI components
- `/lib/services` - Firebase and other service integrations
- `/assets` - Images and fonts
- `/web` - Web-specific files

## Security Note

This repository does not include sensitive Firebase credentials. Make sure to:
1. Never commit your actual Firebase configuration files
2. Use the template files provided and add your own credentials locally
3. Ensure proper Firestore security rules are set up in your Firebase project
