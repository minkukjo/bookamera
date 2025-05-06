import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class RecognitionResultView extends StatefulWidget {
  final String text;

  const RecognitionResultView({super.key, required this.text});

  @override
  State<RecognitionResultView> createState() => _RecognitionResultViewState();
}

class _RecognitionResultViewState extends State<RecognitionResultView> {
  String title = '';
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: AppColors.navyBlueLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, size: 24, color: AppColors.white),
              ),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
            ),
        ],
      ),
      backgroundColor: AppColors.black,
      body: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.black,
        child: SingleChildScrollView(
          child: _isEditing
            ? TextField(
                controller: _textController,
                maxLines: null,
                style: const TextStyle(color: AppColors.white),
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Text(
                  _textController.text,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.black,
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () async {
            await openDialog(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.navyBlue),
            foregroundColor: MaterialStateProperty.all(AppColors.white),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future openDialog(context) async {
    String errorText = '';
    String localTitle = '';
    TextEditingController titleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.black,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter title",
                      hintStyle: const TextStyle(color: AppColors.white),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.navyBlue),
                      ),
                      filled: true,
                      fillColor: AppColors.black,
                    ),
                    onChanged: (value) {
                      localTitle = value;
                      setState(() {
                        errorText = '';
                      });
                    },
                  ),
                  if (errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (localTitle.trim().isEmpty) {
                      setState(() {
                        errorText = 'Please enter a title.';
                      });
                      return;
                    }
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    final List<String> titles = prefs.getStringList("title") ?? [];
                    final List<String> contents = prefs.getStringList("content") ?? [];
                    titles.add(localTitle);
                    contents.add(_textController.text);
                    prefs.setStringList("title", titles);
                    prefs.setStringList("content", contents);
                    Navigator.of(context).pop();
                    toastMessage();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: AppColors.navyBlue),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}

void toastMessage() {
  Fluttertoast.showToast(
    msg: 'Succeed to save!',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColors.navyBlue,
    textColor: Colors.white,
    fontSize: 20.0,
  );
}
