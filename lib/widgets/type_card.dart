import 'package:flutter/material.dart';

class TypeCard extends StatelessWidget {
  final String type;
  final VoidCallback onTap;

  const TypeCard({
    Key? key,
    required this.type,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        title: Text(
          type,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
