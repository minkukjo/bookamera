import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final String text;

  const ResultView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Text(text));
  }
}
