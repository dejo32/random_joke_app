import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke_model.dart';

class ApiService {
  static const baseUrl = 'https://official-joke-api.appspot.com';

  Future<List<String>> fetchJokeTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/types'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load joke types');
    }
  }

  Future<List<Joke>> fetchJokesByType(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/jokes/$type/ten'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((joke) => Joke.fromJson(joke)).toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  Future<Joke> fetchRandomJoke() async {
    final response = await http.get(Uri.parse('$baseUrl/random_joke'));
    if (response.statusCode == 200) {
      return Joke.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load random joke');
    }
  }
}
