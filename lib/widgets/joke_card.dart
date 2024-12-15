import 'package:flutter/material.dart';

class JokeCard extends StatelessWidget {
  final String setup;
  final String punchline;

  const JokeCard({
    Key? key,
    required this.setup,
    required this.punchline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              setup,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              punchline,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
