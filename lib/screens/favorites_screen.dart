import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../widgets/joke_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../models/joke_model.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Joke> _favoriteJokes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoritesService.getFavoriteJokes();
      setState(() {
        _favoriteJokes = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Joke joke) async {
    await _favoritesService.removeFavorite(joke.id);
    await _loadFavorites(); // Refresh the list
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Jokes'),
        backgroundColor: Colors.red[300],
      ),
      body: _isLoading
          ? LoadingIndicator()
          : _favoriteJokes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No favorite jokes yet!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add some jokes to your favorites\nfrom the jokes list',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _favoriteJokes.length,
                  itemBuilder: (context, index) {
                    final joke = _favoriteJokes[index];
                    return JokeCard(
                      joke: joke,
                      showFavoriteButton: true,
                      isFavorite: true,
                      onFavoriteToggle: () => _removeFavorite(joke),
                    );
                  },
                ),
    );
  }
} 