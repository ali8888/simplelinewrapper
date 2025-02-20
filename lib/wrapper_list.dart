import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simplelinewrapper/main.dart';
import 'package:simplelinewrapper/wrapper.dart';
import 'package:simplelinewrapper/wrapper_creation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelinewrapper/wrapping.dart';

class WrapperList extends StatefulWidget {
  const WrapperList({super.key});

  @override
  State<WrapperList> createState() => _WrapperListState();
}

class _WrapperListState extends State<WrapperList> {
  List<Wrapper> wrappers = [];
  bool loaded = false;
  bool processing = false;
  Future<List<Wrapper>> loadWrappers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Wrapper> wrappers = [];
    String name, ls, rs, ec;
    bool indiv;
    List<String> illegals;
    List<List<String>> replacements = [];
    List<String>? replacement;

    List<String>? wrapperList = prefs.getStringList('SLW_wrapperList');
    if (wrapperList == null) {
      await prefs.setStringList('SLW_wrapperList', []);
      wrapperList = [];
    }

    for (int i = 0; i < wrapperList.length; i++) {
      name = prefs.getString('SLW_wrapperName${wrapperList[i]}') ?? '';
      ls = prefs.getString('SLW_wrapperLeftSide${wrapperList[i]}') ?? '';
      rs = prefs.getString('SLW_wrapperRightSide${wrapperList[i]}') ?? '';
      indiv = prefs.getBool('SLW_wrapperIndiv${wrapperList[i]}') ?? true;
      ec = prefs.getString('SLW_wrapperEscape${wrapperList[i]}') ?? '';
      illegals = prefs.getStringList('SLW_wrapperIllegals${wrapperList[i]}') ?? [];
      for (int j = 0; j < (prefs.getInt('SLW_wrapperReplacementsNumber${wrapperList[i]}') ?? 0); j++) {
        replacement = prefs.getStringList('SLW_wrapperReplacements[$j]${wrapperList[i]}');
        if (replacement != null) {
          replacements.add(replacement);
        }
      }
      wrappers += [Wrapper(wrapperList[i], name, ls, rs, indiv, ec, illegals, replacements)];
      replacements = [];
    }

    return wrappers;
  }

  Future<bool> deleteWrapper(String dbname) async {
    setState(
      () {},
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? wrapperList = prefs.getStringList('SLW_wrapperList');
    if (wrapperList == null) {
      return false;
    } else if (!wrapperList.contains(dbname)) {
      return false;
    } else {
      await prefs.remove('SLW_wrapperName$dbname');
      await prefs.remove('SLW_wrapperLeftSide$dbname');
      await prefs.remove('SLW_wrapperRightSide$dbname');
      await prefs.remove('SLW_wrapperIndiv$dbname');
      await prefs.remove('SLW_wrapperEscape$dbname');
      await prefs.remove('SLW_wrapperIllegals$dbname');
      for (int j = 0; j < (prefs.getInt('SLW_wrapperReplacementsNumber$dbname') ?? 0); j++) {
        await prefs.remove('SLW_wrapperReplacements[$j]$dbname');
      }
      await prefs.remove('SLW_wrapperReplacementsNumber$dbname');
      wrapperList.remove(dbname);
      await prefs.setStringList('SLW_wrapperList', wrapperList);
      return true;
    }
  }

  String wrapperExample(Wrapper wrapper) {
    String example = 'This is an "example"';
    for (int i = 0; i < example.length; i++) {
      if (wrapper.illegals.contains(example[i])) {
        example = example.substring(0, i) + wrapper.ec + example.substring(i);
        i++;
      }
    }
    return example;
  }

  Future<void> navigateAndUpdate(BuildContext context, Wrapper wrapper) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => WrapperCreation(mode: WrapperMode.edit, wrapperToEdit: Wrapper(wrapper.dbname, wrapper.name, wrapper.ls, wrapper.rs, wrapper.indiv, wrapper.ec, wrapper.illegals, wrapper.replacements))));
    updateList();
  }

  void updateList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SizedBox(
      width: clampDouble(MediaQuery.of(context).size.width / 2, 600, 1000),
      child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text('Your wrappers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Wrapper>>(
                    future: loadWrappers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading..');
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        wrappers = snapshot.data!;
                        if (wrappers.isEmpty) {
                          return const Text("You haven't made any wrappers yet..");
                        } else {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              for (int i = 0; i < wrappers.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                                  child: Card(
                                      elevation: 3,
                                      child: Stack(alignment: Alignment.centerRight, children: [
                                        InkWell(
                                          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          onTap: () => {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Wrapping(
                                                          wrapper: wrappers[i],
                                                        ))),
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(wrappers[i].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                                    Text("${wrappers[i].ls}${wrapperExample(wrappers[i])}${wrappers[i].rs}", style: TextStyle(fontSize: 16)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  navigateAndUpdate(context, wrappers[i]);
                                                },
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext context) {
                                                        String wrappername = wrappers[i].name;
                                                        return StatefulBuilder(
                                                          builder: (context, setState) {
                                                            return AlertDialog(
                                                              title: Text('Delete "$wrappername"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                                              content: processing
                                                                  ? Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: const [
                                                                        CircularProgressIndicator(),
                                                                        SizedBox(width: 20),
                                                                        Text('Deleting...'),
                                                                      ],
                                                                    )
                                                                  : Text('Are you sure you want to delete this wrapper?'),
                                                              actions: [
                                                                if (!processing)
                                                                  TextButton(
                                                                    child: Text('Cancel'),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                if (!processing)
                                                                  TextButton(
                                                                    child: Text('Delete'),
                                                                    onPressed: () async {
                                                                      setState(() {
                                                                        processing = true;
                                                                      });
                                                                      bool success = await deleteWrapper(wrappers[i].dbname);
                                                                      setState(() {
                                                                        processing = false;
                                                                      });
                                                                      if (!context.mounted) return;
                                                                      Navigator.of(context).pop();

                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(success ? 'Deletion successful' : 'Deletion failed'),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  })
                                            ],
                                          ),
                                        ),
                                      ])),
                                )
                            ],
                          );
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
              ]))),
    )));
  }
}

class WrapperListItem extends StatelessWidget {
  const WrapperListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
