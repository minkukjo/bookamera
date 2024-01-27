import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecognitionResultView extends StatelessWidget {
  final String text;

  const RecognitionResultView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: Text(text))),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () async {
            toastMessage();
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            final List<String>? phrases = prefs.getStringList("phrases");
            if (phrases == null) {
              var phrases = <String>[text];
              prefs.setStringList("phrases", phrases);
            } else {
              phrases.add(text);
              prefs.setStringList("phrases", phrases);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

void toastMessage() {
  // TODO 시간을 더 짧게 할 수 없을지?
  Fluttertoast.showToast(
    msg: 'Succeed to save!',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 20.0,
  );
}
