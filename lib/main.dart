import 'package:flutter/material.dart';
import './screens/joke_types_screen.dart';
import './screens/random_joke_screen.dart';
import './screens/jokes_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => JokeTypesScreen(),
        '/random-joke': (context) => RandomJokeScreen(),
      },
    );
  }
}
