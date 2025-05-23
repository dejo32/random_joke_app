import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/joke_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_jokes';

  // Get all favorite jokes
  Future<List<Joke>> getFavoriteJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    return favoritesJson.map((jokeJson) {
      final Map<String, dynamic> jokeMap = json.decode(jokeJson);
      return Joke.fromJson(jokeMap);
    }).toList();
  }

  // Add a joke to favorites
  Future<void> addFavorite(Joke joke) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteJokes();
    
    // Check if joke is already in favorites
    if (!favorites.any((fav) => fav.id == joke.id)) {
      favorites.add(joke);
      final favoritesJson = favorites.map((joke) => json.encode(joke.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  // Remove a joke from favorites
  Future<void> removeFavorite(int jokeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteJokes();
    
    favorites.removeWhere((joke) => joke.id == jokeId);
    final favoritesJson = favorites.map((joke) => json.encode(joke.toJson())).toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  // Check if a joke is in favorites
  Future<bool> isFavorite(int jokeId) async {
    final favorites = await getFavoriteJokes();
    return favorites.any((joke) => joke.id == jokeId);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Joke joke) async {
    final isCurrentlyFavorite = await isFavorite(joke.id);
    
    if (isCurrentlyFavorite) {
      await removeFavorite(joke.id);
      return false;
    } else {
      await addFavorite(joke);
      return true;
    }
  }
} 