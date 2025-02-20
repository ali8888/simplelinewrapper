import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelinewrapper/main.dart';
import 'package:simplelinewrapper/wrapper.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WrapperCreation extends StatefulWidget {
  final WrapperMode mode;
  final Wrapper wrapperToEdit;
  // Name text controller
  final nameController = TextEditingController();
  // Left side text controller
  final lsController = TextEditingController();
  // Right side text controller
  final rsController = TextEditingController();
  // Escape character text controller
  final ecController = TextEditingController();
  // Illegal character text controller
  final icController = TextEditingController();
  // Word To Replace text controller
  final wrController = TextEditingController();
  // Replacement text controller (Text to replace)
  final retController = TextEditingController();
  // Replacement text controller (Replacement)
  final rerController = TextEditingController();

  WrapperCreation({super.key, required this.mode, required this.wrapperToEdit}) {
    if (mode == WrapperMode.edit) {
      nameController.value = TextEditingValue(text: wrapperToEdit.name);
      lsController.value = TextEditingValue(text: wrapperToEdit.ls);
      rsController.value = TextEditingValue(text: wrapperToEdit.rs);
      ecController.value = TextEditingValue(text: wrapperToEdit.ec);
    }
  }

  @override
  State<WrapperCreation> createState() => _WrapperCreationState();
}

class _WrapperCreationState extends State<WrapperCreation> {
  final _formKey = GlobalKey<FormState>();
  final _trKey = GlobalKey<FormState>();
  final _icKey = GlobalKey<FormState>();
  bool indivInput = true;
  bool indivInputModified = false;

  // bool used to lock the form while processing data
  bool processing = false;

  String _textFromFile = "Loading..";

  @override
  void initState() {
    super.initState();
    _loadTextFromFile();
  }

  Future<void> _loadTextFromFile() async {
    final String response = await rootBundle.loadString('help_content.txt');
    setState(() {
      _textFromFile = response;
    });
  }

  Future<bool> saveWrapper(BuildContext context, String name, String leftside, String rightside, bool indiv, String escape, List<String> illegals, List<List<String>> replacements) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<bool> validation = [];
    List<String>? wrapperList = prefs.getStringList('SLW_wrapperList');
    if (wrapperList == null) {
      validation.add(await prefs.setStringList('SLW_wrapperList', []));
      wrapperList = [];
    }

    var dbname = "${name.replaceAll(' ', '')}_1";
    int i = 1;
    while (prefs.getStringList('SLW_wrapperList')?.contains(dbname) ?? false) {
      i++;
      dbname = dbname.substring(0, dbname.length - 1) + i.toString();
    }

    validation.add(await prefs.setString("SLW_wrapperName$dbname", name));
    validation.add(await prefs.setString('SLW_wrapperLeftSide$dbname', leftside));
    validation.add(await prefs.setString('SLW_wrapperRightSide$dbname', rightside));
    validation.add(await prefs.setBool('SLW_wrapperIndiv$dbname', indiv));
    validation.add(await prefs.setString('SLW_wrapperEscape$dbname', escape));
    validation.add(await prefs.setStringList('SLW_wrapperIllegals$dbname', illegals));
    for (int i = 0; i < replacements.length; i++) {
      validation.add(await prefs.setStringList('SLW_wrapperReplacements[$i]$dbname', replacements[i]));
    }
    validation.add(await prefs.setInt('SLW_wrapperReplacementsNumber$dbname', replacements.length));
    wrapperList.add(dbname);
    validation.add(await prefs.setStringList('SLW_wrapperList', wrapperList));

    return !validation.contains(false);
  }

  Future<bool> modifyWrapper(String dbname, String name, String leftside, String rightside, bool indiv, String escape, List<String> illegals, List<List<String>> replacements) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? wrapperList = prefs.getStringList('SLW_wrapperList');
    if (wrapperList == null) {
      // Could be replaced by an error code
      return false;
    } else if (!wrapperList.contains(dbname)) {
      // Could be replaced by an error code
      return false;
    }

    await prefs.setString("SLW_wrapperName$dbname", name);
    await prefs.setString('SLW_wrapperLeftSide$dbname', leftside);
    await prefs.setString('SLW_wrapperRightSide$dbname', rightside);
    await prefs.setBool('SLW_wrapperIndiv$dbname', indiv);
    await prefs.setString('SLW_wrapperEscape$dbname', escape);
    await prefs.setStringList('SLW_wrapperIllegals$dbname', illegals);
    for (int i = 0; i < replacements.length; i++) {
      await prefs.setStringList('SLW_wrapperReplacements[$i]$dbname', replacements[i]);
    }
    await prefs.setInt('SLW_wrapperReplacementsNumber$dbname', replacements.length);
    return true;
  }

  void updateForm() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<String> icList = widget.wrapperToEdit.illegals;
    List<List<String>> trList = widget.wrapperToEdit.replacements;
    bool indiv = widget.wrapperToEdit.indiv;

    return Scaffold(
        body: Center(
      child: SizedBox(
        width: clampDouble(MediaQuery.of(context).size.width / 2, 600, 1000),
        child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: processing
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                              ),
                              if (widget.mode == WrapperMode.create) Flexible(child: const Text('Create a new wrapper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26))),
                              if (widget.mode == WrapperMode.edit) Flexible(child: const Text('Edit Wrapper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26))),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.help),
                              onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: clampDouble(MediaQuery.of(context).size.width, 0, 400),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text('Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                icon: Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: ListView(
                                              shrinkWrap: true,
                                              children: [
                                                Text(_textFromFile)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a name';
                        }
                        return null;
                      },
                      readOnly: processing,
                      controller: widget.nameController,
                      decoration: InputDecoration(labelText: 'Name', hintText: 'My wrapper'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: widget.lsController,
                      readOnly: processing,
                      decoration: InputDecoration(labelText: 'Left Side', hintText: 'Example : out.println("'),
                    ),
                    TextField(
                      controller: widget.rsController,
                      readOnly: processing,
                      decoration: const InputDecoration(labelText: "Right Side", hintText: 'Example : ");'),
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: (indivInputModified) ? indivInput : indiv,
                            onChanged: processing
                                ? null
                                : (bool? value) {
                                    setState(() {
                                      indivInput = value!;
                                      indivInputModified = true;
                                    });
                                  }),
                        const Text("Wrap each line individually")
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            controller: widget.ecController,
                            decoration: const InputDecoration(labelText: "Escape Character/Text", hintText: 'Example : \\'),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        TextButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Manage Illegal Characters"),
                              SizedBox(width: 5),
                              Badge(
                                label: Text(icList.length.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                textColor: ((Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.black),
                                backgroundColor: Colors.transparent,
                              )
                            ],
                          ),
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(builder: (context, setState) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: clampDouble(MediaQuery.of(context).size.width, 0, 400),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text('Illegal characters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  updateForm();
                                                  Navigator.pop(context);
                                                },
                                                icon: Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                          Form(
                                            key: _icKey,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 5),
                                                Flexible(
                                                  child: TextFormField(
                                                      maxLength: 1,
                                                      controller: widget.icController,
                                                      decoration: const InputDecoration(labelText: "Type an illegal character here...", hintText: 'Example : "'),
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return "Cannot add empty illegal characters.";
                                                        } else if (icList.contains(value)) {
                                                          return "This illegal character exists already.";
                                                        }
                                                        return null;
                                                      }),
                                                ),
                                                SizedBox(width: 5),
                                                IconButton.filled(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_icKey.currentState!.validate()) {
                                                          icList.add(widget.icController.text);
                                                          widget.icController.clear();
                                                        }
                                                      });
                                                    })
                                              ],
                                            ),
                                          ),
                                          if (icList.isNotEmpty)
                                            Flexible(
                                              child: ListView(children: [
                                                Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 4.0,
                                                  children: List<Widget>.generate(icList.length, (index) {
                                                    return InputChip(
                                                      label: Text(icList[index]),
                                                      onDeleted: () => setState(() {
                                                        icList.removeAt(index);
                                                      }),
                                                      deleteIcon: Icon(Icons.close),
                                                    );
                                                  }),
                                                ),
                                              ]),
                                            ),
                                          if (icList.isEmpty) Expanded(child: const Text("Illegal characters will appear here when you add them.")),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Manage Text Replacements"),
                            SizedBox(width: 5),
                            Badge(
                              label: Text(trList.length.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                              textColor: ((Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.black),
                              backgroundColor: Colors.transparent,
                            )
                          ],
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (context, setState) {
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: clampDouble(MediaQuery.of(context).size.width, 0, 400),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text('Text Replacements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                updateForm();
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        Form(
                                          key: _trKey,
                                          child: Row(
                                            children: [
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: TextFormField(
                                                    controller: widget.retController,
                                                    decoration: const InputDecoration(
                                                      labelText: "Text to replace..",
                                                    ),
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return "The text to replace should not be empty.";
                                                      }
                                                      return null;
                                                    }),
                                              ),
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: TextField(
                                                  controller: widget.rerController,
                                                  decoration: const InputDecoration(
                                                    labelText: "Replacement..",
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              IconButton.filled(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (_trKey.currentState!.validate()) {
                                                        trList.add([widget.retController.text, widget.rerController.text]);
                                                        widget.retController.clear();
                                                        widget.rerController.clear();
                                                      }
                                                    });
                                                  })
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        if (trList.isNotEmpty)
                                          Flexible(
                                            child: ListView(children: [
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: List<Widget>.generate(trList.length, (index) {
                                                  return InputChip(
                                                    label: Text("${trList[index][0]} → ${trList[index][1]}"),
                                                    onDeleted: () => setState(() {
                                                      trList.removeAt(index);
                                                    }),
                                                    deleteIcon: Icon(Icons.close),
                                                  );
                                                }),
                                              ),
                                            ]),
                                          ),
                                        if (trList.isEmpty) Expanded(child: const Text("Text replacements will appear here when you add them.")),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ),

                    // Old Illegal character list
                    /*
                    if (icList.isNotEmpty)
                      Flexible(
                        child: ListView(children: [
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children:
                                List<Widget>.generate(icList.length, (index) {
                              return InputChip(
                                label: Text(icList[index]),
                                onDeleted: () => setState(() {
                                  icList.removeAt(index);
                                }),
                                deleteIcon: Icon(Icons.close),
                              );
                            }),
                          ),
                        ]),
                      ),
                    if (icList.isEmpty)
                      Expanded(
                          child: const Text(
                              "Illegal characters will appear here when you add them.")),
                    */
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.mode == WrapperMode.create)
                          TextButton.icon(
                              label: Text('Create'),
                              icon: Icon(Icons.add),
                              onPressed: processing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        processing = true;
                                        updateForm();
                                        if (await saveWrapper(context, widget.nameController.text, widget.lsController.text, widget.rsController.text, (indivInputModified) ? indivInput : indiv, widget.ecController.text, icList, trList)) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrapper created successfully")));
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          processing = false;
                                          updateForm();
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unknown error has occured when trying to create Wrapper.")));
                                        }
                                      }
                                    }),
                        if (widget.mode == WrapperMode.edit)
                          TextButton.icon(
                              label: Text('Save'),
                              icon: Icon(Icons.save),
                              onPressed: processing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        processing = true;
                                        updateForm();
                                        if (await modifyWrapper(widget.wrapperToEdit.dbname, widget.nameController.text, widget.lsController.text, widget.rsController.text, (indivInputModified) ? indivInput : indiv, widget.ecController.text, icList, trList)) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrapper saved successfully")));
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          processing = false;
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unknown error has occured when trying to save Wrapper.")));
                                        }
                                      }
                                    }),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    ));
  }
}
