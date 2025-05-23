import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../models/joke_model.dart';

class JokesListScreen extends StatelessWidget {
  final String type;
  final ApiService apiService = ApiService();

  JokesListScreen({required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jokes of Type: $type'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            tooltip: 'View Favorites',
          ),
        ],
      ),
      body: FutureBuilder<List<Joke>>(
        future: apiService.fetchJokesByType(type),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(message: 'Failed to load jokes.');
          } else {
            final jokes = snapshot.data ?? [];
            return ListView.builder(
              itemCount: jokes.length,
              itemBuilder: (context, index) {
                return JokeCard(
                  joke: jokes[index],
                  showFavoriteButton: true,
                );
              },
            );
          }
        },
      ),
    );
  }
}
