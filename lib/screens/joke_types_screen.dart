import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/type_card.dart';
import './jokes_list_screen.dart';
import './random_joke_screen.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class JokeTypesScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke Types'),
        actions: [
          IconButton(
            icon: Icon(Icons.casino),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RandomJokeScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: apiService.fetchJokeTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(message: 'Failed to load joke types.');
          } else {
            final jokeTypes = snapshot.data ?? [];
            return ListView.builder(
              itemCount: jokeTypes.length,
              itemBuilder: (context, index) {
                return TypeCard(
                  type: jokeTypes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JokesListScreen(type: jokeTypes[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}