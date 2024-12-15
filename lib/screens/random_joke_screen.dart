import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../models/joke_model.dart';

class RandomJokeScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Joke'),
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
                setup: joke.setup,
                punchline: joke.punchline,
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
