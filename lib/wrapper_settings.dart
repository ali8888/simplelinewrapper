import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelinewrapper/main.dart';

enum KeyBindBase { ctrl, alt, shift }

Future<KeyBindBase> getKeybind1() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? keyBindBase = prefs.getString("SLW_keybind1");
  if (keyBindBase == null) {
    return KeyBindBase.ctrl;
  } else {
    switch (keyBindBase) {
      case 'KeyBindBase.ctrl':
        return KeyBindBase.ctrl;
      case 'KeyBindBase.alt':
        return KeyBindBase.alt;
      case 'KeyBindBase.shift':
        return KeyBindBase.shift;
      default:
        return KeyBindBase.ctrl;
    }
  }
}

Future<int> getKeybind2() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int? keyBindBase = prefs.getInt("SLW_keybind2");
  if (keyBindBase == null) {
    return 0;
  } else {
    return keyBindBase;
  }
}

class WrapperSettings extends StatefulWidget {
  const WrapperSettings({super.key});

  @override
  State<WrapperSettings> createState() => _WrapperSettingsState();
}

class _WrapperSettingsState extends State<WrapperSettings> {
  FocusNode keybindListenerNode = FocusNode();
  bool processing = false;

  Future<void> saveKeyCombo(KeyBindBase keyBindBase, LogicalKeyboardKey key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("SLW_keybind1", keyBindBase.toString());
    prefs.setInt("SLW_keybind2", key.keyId);
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
                    const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Card(
                            elevation: 3,
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ChangeThemeDialog(),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: const [
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.palette)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Change theme", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Flexible(
                                            child: Text("Change the theme of the app.", style: TextStyle(fontSize: 14), softWrap: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.arrow_forward)),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Card(
                            elevation: 3,
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onTap: () {
                                final StreamController<String> kcscontroller = StreamController<String>();

                                void setKeyCombo(String key) {
                                  setState(() {
                                    kcscontroller.sink.add(key);
                                  });
                                }

                                getKeybind1().then((value1) {
                                  setState(() {
                                    getKeybind2().then((value2) {
                                      setState(() {
                                        switch (value1) {
                                          case KeyBindBase.ctrl:
                                            kcscontroller.sink.add('Ctrl + ${LogicalKeyboardKey.findKeyByKeyId(value2)?.keyLabel ?? 'Enter'}');
                                            break;
                                          case KeyBindBase.alt:
                                            kcscontroller.sink.add('Alt + ${LogicalKeyboardKey.findKeyByKeyId(value2)?.keyLabel ?? 'Enter'}');
                                            break;
                                          case KeyBindBase.shift:
                                            kcscontroller.sink.add('Shift + ${LogicalKeyboardKey.findKeyByKeyId(value2)?.keyLabel ?? 'Enter'} ');
                                            break;
                                        }
                                      });
                                    });
                                  });
                                });
                                Widget getKeyComboText() {
                                  keybindListenerNode.requestFocus();
                                  return StreamBuilder<String>(
                                    stream: kcscontroller.stream,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text('Awaiting input...');
                                      }
                                      return Text('Combo pressed: ${snapshot.data}');
                                    },
                                  );
                                }

                                showDialog<String>(
                                    context: context,
                                    builder: (context) => Dialog(
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
                                                        child: Text('Change wrapping keybind', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        icon: Icon(Icons.close),
                                                      ),
                                                    ],
                                                  ),
                                                  Text('Press desired keybind combination'),
                                                  const SizedBox(height: 10),
                                                  Text('Combo should be in the form of <Ctrl/Shift/Alt> + <key>'),
                                                  const SizedBox(height: 10),
                                                  Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: KeyboardListener(
                                                        focusNode: keybindListenerNode,
                                                        onKeyEvent: (event) {
                                                          if (event is KeyDownEvent) {
                                                            final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
                                                            final isAltPressed = HardwareKeyboard.instance.isAltPressed;
                                                            final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                                                            final key = event.logicalKey;
                                                            if (isCtrlPressed) {
                                                              setKeyCombo('Ctrl + ${key.keyLabel}');
                                                              saveKeyCombo(KeyBindBase.ctrl, key);
                                                            } else if (isAltPressed) {
                                                              setKeyCombo('Alt + ${key.keyLabel}');
                                                              saveKeyCombo(KeyBindBase.alt, key);
                                                            } else if (isShiftPressed) {
                                                              setKeyCombo('Shift + ${key.keyLabel}');
                                                              saveKeyCombo(KeyBindBase.shift, key);
                                                            }
                                                          }
                                                        },
                                                        child: getKeyComboText(),
                                                      )),
                                                  TextButton(
                                                    child: Text('Reset to default'),
                                                    onPressed: () {
                                                      setKeyCombo('Ctrl + Enter');
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                FocusScope.of(context).requestFocus(keybindListenerNode);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: const [
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.keyboard)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Change wrapping keybind", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Flexible(
                                            child: Text("Change the keybind combination used to automatically wrap text.", style: TextStyle(fontSize: 14), softWrap: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.arrow_forward)),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Card(
                            elevation: 3,
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: !processing,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text('Delete all data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                          content: processing
                                              ? Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    CircularProgressIndicator(),
                                                    SizedBox(width: 20),
                                                    Text('Deleting...'),
                                                  ],
                                                )
                                              : Text('Warning, this action is irreversible and will wipe all wrappers stored on the browser.'),
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
                                                  List<bool> status = [];
                                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  List<String>? wList = prefs.getStringList("SLW_wrapperList");
                                                  if (wList == null) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There are no wrappers to delete.")));
                                                      Navigator.pop(context);
                                                    }
                                                  } else {
                                                    for (int i = 0; i < wList.length; i++) {
                                                      status.add(await prefs.remove('SLW_wrapperName${wList[i]}'));
                                                      status.add(await prefs.remove('SLW_wrapperLeftSide${wList[i]}'));
                                                      status.add(await prefs.remove('SLW_wrapperRightSide${wList[i]}'));
                                                      status.add(await prefs.remove('SLW_wrapperIndiv${wList[i]}'));
                                                      status.add(await prefs.remove('SLW_wrapperEscape${wList[i]}'));
                                                      status.add(await prefs.remove('SLW_wrapperIllegals${wList[i]}'));
                                                      for (int j = 0; j < (prefs.getInt('SLW_wrapperReplacementsNumber${wList[i]}') ?? 0); j++) {
                                                        status.add(await prefs.remove('SLW_wrapperReplacements[$j]${wList[i]}'));
                                                      }
                                                      status.add(await prefs.remove('SLW_wrapperReplacementsNumber${wList[i]}'));
                                                    }
                                                    status.add(await prefs.setStringList("SLW_wrapperList", []));
                                                  }
                                                  setState(() {
                                                    processing = false;
                                                  });
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).pop();

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(!status.contains(false) ? 'Deletion successful' : 'An unexpected issue has occurred. Consider clearing your cookies for this site.'),
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
                                
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: const [
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.delete_forever)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Delete all data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Flexible(
                                            child: Text("Remove every existing wrapper stored on the browser.", style: TextStyle(fontSize: 14), softWrap: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.arrow_forward)),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ]))),
    )));
  }
}
