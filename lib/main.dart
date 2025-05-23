import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './screens/joke_types_screen.dart';
import './screens/random_joke_screen.dart';
import './screens/jokes_list_screen.dart';
import './screens/favorites_screen.dart';
import './screens/settings_screen.dart';
import './services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyBtOFKBQ_C1O_V_1hz-1eS5pSjleHefhrk",
        authDomain: "random-joke-app-65806.firebaseapp.com",
        projectId: "random-joke-app-65806",
        storageBucket: "random-joke-app-65806.firebasestorage.app",
        messagingSenderId: "526051922550",
        appId: "1:526051922550:web:78e7c3f54cc22495900557"));
  }else{
    await Firebase.initializeApp();
  }

  // Initialize notification service
  await NotificationService.initialize();
  
  // Set navigator key for notifications
  NotificationService.setNavigatorKey(navigatorKey);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => JokeTypesScreen(),
        '/random-joke': (context) => RandomJokeScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
