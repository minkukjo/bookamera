import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants/colors.dart';

class PhraseListView extends StatefulWidget {
  const PhraseListView({super.key});

  @override
  State createState() => PhraseState();
}

class PhraseState extends State<PhraseListView> {
  List<String> _uniqueKeys = [];
  List<String> _titles = [];
  List<String> _contents = [];
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadAndInitData();
  }

  Future<void> _loadAndInitData() async {
    final prefs = await SharedPreferences.getInstance();
    final titles = prefs.getStringList('title') ?? [];
    final contents = prefs.getStringList('content') ?? [];
    List<String>? keys = prefs.getStringList('key');

    // If keys don't exist or mismatched, regenerate them
    if (keys == null || keys.length != titles.length) {
      keys = List.generate(titles.length, (_) => UniqueKey().toString());
      await prefs.setStringList('key', keys);
    }

    setState(() {
      _titles = titles.reversed.toList();
      _contents = contents.reversed.toList();
      _uniqueKeys = keys!.reversed.toList();
    });
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _titles.removeAt(index);
      _contents.removeAt(index);
      _uniqueKeys.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('title', _titles);
    await prefs.setStringList('content', _contents);
    await prefs.setStringList('key', _uniqueKeys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved List"),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        color: AppColors.black,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _contents.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              key: Key(_uniqueKeys[index]),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.15,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppColors.black,
                            title: const Text('Delete', style: TextStyle(color: AppColors.white)),
                            content: const Text('Are you sure you want to delete this item?', style: TextStyle(color: AppColors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel', style: TextStyle(color: AppColors.navyBlue)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteItem(index);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: AppColors.white,
                    icon: Icons.delete,
                    flex: 1,
                    padding: EdgeInsets.zero,
                    spacing: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = _expandedIndex == index ? null : index;
                      });
                    },
                    child: Container(
                      height: 50,
                      color: AppColors.navyBlue,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _titles[index],
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    key: Key('crossfade_${_uniqueKeys[index]}'),
                    firstChild: Container(),
                    secondChild: Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.black,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _contents[index],
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                    crossFadeState: _expandedIndex == index
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
