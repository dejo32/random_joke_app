import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../models/joke_model.dart';
import './favorites_screen.dart';

class RandomJokeScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Joke'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
            tooltip: 'View Favorites',
          ),
        ],
      ),
      body: FutureBuilder<Joke>(
        future: apiService.fetchRandomJoke(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(message: 'Failed to load random joke.');
          } else if (snapshot.hasData) {
            final joke = snapshot.data!;
            return Center(
              child: JokeCard(
                joke: joke,
                showFavoriteButton: true,
              ),
            );
          } else {
            return ErrorMessage(message: 'Unexpected error occurred.');
          }
        },
      ),
    );
  }
}
