import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Text(text));
  }
}
