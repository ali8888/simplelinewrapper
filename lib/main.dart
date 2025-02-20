import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelinewrapper/wrapper.dart';
import 'package:simplelinewrapper/wrapper_creation.dart';
import 'package:simplelinewrapper/wrapper_list.dart';
import 'package:simplelinewrapper/wrapper_settings.dart';
import 'package:url_launcher/url_launcher.dart';

enum WrapperMode { create, edit }

void main() {
  runApp(const SLW());
}

class SLW extends StatefulWidget {
  const SLW({super.key});

  @override
  State<SLW> createState() => _SLWState();
}

class _SLWState extends State<SLW> {
  ThemeMode? _themeMode;

  Color? _primaryColor;

  @override
  void initState() {
    getCurrentPrimaryColor().then((value) {
      setState(() {
        _primaryColor = value;
      });
    });
    getCurrentTheme().then((value) {
      setState(() {
        _themeMode = value;
      });
    });
    super.initState();
  }

  Future<Color> getCurrentPrimaryColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? color = prefs.getString('SLW_primaryColor');
    if (color == null) {
      prefs.setString('SLW_primaryColor', 'deepPurple');
      return Colors.deepPurpleAccent;
    } else {
      switch (color) {
        case 'red':
          return Colors.redAccent;
        case 'pink':
          return Colors.pinkAccent;
        case 'purple':
          return Colors.purpleAccent;
        case 'deepPurple':
          return Colors.deepPurpleAccent;
        case 'indigo':
          return Colors.indigoAccent;
        case 'blue':
          return Colors.blueAccent;
        case 'lightBlue':
          return Colors.lightBlueAccent;
        case 'cyan':
          return Colors.cyanAccent;
        case 'teal':
          return Colors.tealAccent;
        case 'green':
          return Colors.greenAccent;
        case 'lightGreen':
          return Colors.lightGreenAccent;
        case 'lime':
          return Colors.limeAccent;
        case 'yellow':
          return Colors.yellowAccent;
        case 'amber':
          return Colors.amberAccent;
        case 'orange':
          return Colors.orangeAccent;
        case 'deepOrange':
          return Colors.deepOrangeAccent;
        default:
          return Colors.deepPurpleAccent;
      }
    }
  }

  Future<ThemeMode> getCurrentTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('SLW_themeMode');
    if (theme == null) {
      prefs.setString('SLW_themeMode', 'ThemeMode.system');
      return ThemeMode.system;
    } else {
      switch (theme) {
        case 'ThemeMode.light':
          return ThemeMode.light;
        case 'ThemeMode.dark':
          return ThemeMode.dark;
        case 'ThemeMode.system':
          return ThemeMode.system;
        default:
          return ThemeMode.system;
      }
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void setPrimaryColor(Color primaryColor) {
    setState(() {
      _primaryColor = primaryColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Simple Line Wrapper', debugShowCheckedModeBanner: false, themeMode: _themeMode ?? ThemeMode.light, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor ?? Colors.deepPurpleAccent), useMaterial3: true, brightness: Brightness.light), darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor ?? Colors.deepPurpleAccent, brightness: Brightness.dark), useMaterial3: true, brightness: Brightness.dark), home: const MyHomePage(title: 'Simple Line Wrapper'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String version = "1.0-rc1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: clampDouble(MediaQuery.of(context).size.width / 4, 400, 600),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              if((Theme.of(context).brightness == Brightness.dark))
              SizedBox(height: 200, child: Image.asset("assets/logo_light.png")),
              if((Theme.of(context).brightness == Brightness.light))
              SizedBox(height: 200, child: Image.asset("assets/logo_dark.png")),
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WrapperCreation(
                                  mode: WrapperMode.create,
                                  wrapperToEdit: Wrapper(),
                                ))),
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Expanded(
                          child: Text(
                            'Create a new wrapper',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WrapperList())),
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Expanded(
                          child: Text(
                            'Use an existing wrapper',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: [
                  TextButton.icon(
                      label: Text('Settings'),
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WrapperSettings()));
                      }),
                  TextButton.icon(
                    label: Text('About'),
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog<String>(
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
                                        child: Text('Simple Line Wrapper $version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('a Web app that allows you to wrap text/code between predefined text parts, supports setting up an escape character, illegal characters and text replacements.'),
                                  const SizedBox(height: 20),
                                  const Text('© 2025 Lymesque'),
                                  TextButton.icon(
                                    icon: FaIcon(FontAwesomeIcons.github),
                                    onPressed: () async {
                                      final Uri url = Uri.parse('https://www.github.com/ali8888/simplelinewrapper');
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        throw Exception('Could not launch $url');
                                      }
                                    },
                                    label: const Text('Source'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeThemeDialog extends StatefulWidget {
  const ChangeThemeDialog({super.key});

  @override
  State<ChangeThemeDialog> createState() => _ChangeThemeDialogState();
}

class _ChangeThemeDialogState extends State<ChangeThemeDialog> {
  Future<void> saveCurrentTheme(Color color, ThemeMode? themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeMode != null) {
      prefs.setString('SLW_themeMode', themeMode.toString());
    }
    switch (color) {
      case Colors.redAccent:
        prefs.setString('SLW_primaryColor', 'red');
      case Colors.pinkAccent:
        prefs.setString('SLW_primaryColor', 'pink');
      case Colors.purpleAccent:
        prefs.setString('SLW_primaryColor', 'purple');
      case Colors.deepPurpleAccent:
        prefs.setString('SLW_primaryColor', 'deepPurple');
      case Colors.indigoAccent:
        prefs.setString('SLW_primaryColor', 'indigo');
      case Colors.blueAccent:
        prefs.setString('SLW_primaryColor', 'blue');
      case Colors.lightBlueAccent:
        prefs.setString('SLW_primaryColor', 'lightBlue');
      case Colors.cyanAccent:
        prefs.setString('SLW_primaryColor', 'cyan');
      case Colors.tealAccent:
        prefs.setString('SLW_primaryColor', 'teal');
      case Colors.greenAccent:
        prefs.setString('SLW_primaryColor', 'green');
      case Colors.lightGreenAccent:
        prefs.setString('SLW_primaryColor', 'lightGreen');
      case Colors.limeAccent:
        prefs.setString('SLW_primaryColor', 'lime');
      case Colors.yellowAccent:
        prefs.setString('SLW_primaryColor', 'yellow');
      case Colors.amberAccent:
        prefs.setString('SLW_primaryColor', 'amber');
      case Colors.orangeAccent:
        prefs.setString('SLW_primaryColor', 'orange');
      case Colors.deepOrangeAccent:
        prefs.setString('SLW_primaryColor', 'deepOrange');
      default:
        prefs.setString('SLW_primaryColor', 'deepPurple');
    }
  }

  Widget getThemeModeOption(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.light_mode),
            ),
            Text('Light')
          ],
        );
      case ThemeMode.dark:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.dark_mode),
            ),
            Text('Dark')
          ],
        );
      case ThemeMode.system:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.computer),
            ),
            Text('System')
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.findAncestorStateOfType<_SLWState>();
    Color selectedColor = app?._primaryColor ?? Colors.deepPurpleAccent;
    ThemeMode? selectedThemeMode = app?._themeMode ?? ThemeMode.system;

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
                    child: Text('Change theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Text('Pick a theme'),
              const SizedBox(height: 12),
              DropdownButton<ThemeMode>(
                borderRadius: BorderRadius.circular(10),
                underline: Container(),
                value: selectedThemeMode,
                onChanged: (ThemeMode? newValue) {
                  setState(() {
                    selectedThemeMode = newValue;
                    saveCurrentTheme(selectedColor, selectedThemeMode);
                  });
                  final app = context.findAncestorStateOfType<_SLWState>();
                  app?.setThemeMode(newValue!);
                },
                items: ThemeMode.values
                    .map((ThemeMode themeMode) => DropdownMenuItem<ThemeMode>(
                          value: themeMode,
                          child: getThemeModeOption(themeMode),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              const Text('Pick an accent color'),
              const SizedBox(height: 10),
              Wrap(
                  alignment: WrapAlignment.center,
                  children: Colors.accents
                      .map((color) => InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                                saveCurrentTheme(selectedColor, selectedThemeMode);
                              });
                              final app = context.findAncestorStateOfType<_SLWState>();
                              app?.setPrimaryColor(color);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? ((Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.black54) : Colors.transparent, width: 5.0)),
                              ),
                            ),
                          ))
                      .toList()),
            ],
          ),
        ),
      ),
    );
  }
}
