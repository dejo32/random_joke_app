import 'package:flutter/material.dart';
import '../models/joke_model.dart';
import '../services/favorites_service.dart';

class JokeCard extends StatefulWidget {
  final Joke? joke;
  final String? setup;
  final String? punchline;
  final bool showFavoriteButton;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const JokeCard({
    Key? key,
    this.joke,
    this.setup,
    this.punchline,
    this.showFavoriteButton = false,
    this.isFavorite,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _JokeCardState createState() => _JokeCardState();
}

class _JokeCardState extends State<JokeCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite ?? false;
    if (widget.joke != null && widget.showFavoriteButton && widget.isFavorite == null) {
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.joke != null) {
      final isFav = await _favoritesService.isFavorite(widget.joke!.id);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.joke == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onFavoriteToggle != null) {
        widget.onFavoriteToggle!();
      } else {
        final newFavoriteStatus = await _favoritesService.toggleFavorite(widget.joke!);
        setState(() {
          _isFavorite = newFavoriteStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newFavoriteStatus ? 'Added to favorites!' : 'Removed from favorites!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySetup = widget.joke?.setup ?? widget.setup ?? '';
    final displayPunchline = widget.joke?.punchline ?? widget.punchline ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displaySetup,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        displayPunchline,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                if (widget.showFavoriteButton && widget.joke != null)
                  _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: _toggleFavorite,
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
