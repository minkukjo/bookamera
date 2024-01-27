import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhraseListView extends StatefulWidget {
  PhraseListView({super.key});

  @override
  State createState() => PhraseState();
}

class PhraseState extends State<PhraseListView> {
  late List<String> _phrases;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List"),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _phrases.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              color: Colors.orange,
              child: Center(child: Text('Entry ${_phrases[index]}')),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  _loadPhrases() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _phrases = (prefs.getStringList("phrases") ?? []);
    });
  }
}
