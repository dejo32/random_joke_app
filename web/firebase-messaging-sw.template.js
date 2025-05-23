// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
// 
// INSTRUCTIONS:
// 1. Copy this file to 'firebase-messaging-sw.js'
// 2. Replace all placeholder values with your actual Firebase configuration
// 3. Get your configuration from: https://console.firebase.google.com/
// 4. NEVER commit the real firebase-messaging-sw.js file to version control!

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// REPLACE THESE VALUES WITH YOUR ACTUAL FIREBASE CONFIGURATION!
firebase.initializeApp({
  apiKey: 'YOUR_WEB_API_KEY_HERE',
  authDomain: 'YOUR_PROJECT_ID_HERE.firebaseapp.com',
  projectId: 'YOUR_PROJECT_ID_HERE',
  storageBucket: 'YOUR_PROJECT_ID_HERE.firebasestorage.app',
  messagingSenderId: 'YOUR_SENDER_ID_HERE',
  appId: 'YOUR_WEB_APP_ID_HERE'
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Handle background messages. This is called when your app is in the background
// or not focused, and the user receives a push notification.
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Random Joke App';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new joke waiting!',
    icon: '/favicon.png',
    badge: '/favicon.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click events
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');

  event.notification.close();

  // This looks to see if the current window is already open and focuses if it is
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then(function(clientList) {
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === self.location.origin && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
}); 