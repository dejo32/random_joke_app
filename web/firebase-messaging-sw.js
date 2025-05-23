// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
firebase.initializeApp({
  apiKey: 'AIzaSyBtOFKBQ_C1O_V_1hz-1eS5pSjleHefhrk',
  authDomain: 'random-joke-app-65806.firebaseapp.com',
  projectId: 'random-joke-app-65806',
  storageBucket: 'random-joke-app-65806.firebasestorage.app',
  messagingSenderId: '526051922550',
  appId: '1:526051922550:web:e4d706d29cfe6966900557'
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