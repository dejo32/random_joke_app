import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
