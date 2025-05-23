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

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
