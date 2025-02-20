import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelinewrapper/wrapper.dart';
import 'package:simplelinewrapper/wrapper_settings.dart';

class Wrapping extends StatefulWidget {
  final Wrapper wrapper;

  const Wrapping({super.key, required this.wrapper});

  @override
  State<Wrapping> createState() => _WrappingState();
}

class _WrappingState extends State<Wrapping> {
  final TextEditingController _controller = TextEditingController();
  LogicalKeyboardKey keybind1 = LogicalKeyboardKey.control;
  LogicalKeyboardKey keybind2 = LogicalKeyboardKey.enter;

  @override
  void initState() {
    super.initState();
    getKeybind1().then((value) {
      setState(() {
        switch (value) {
          case KeyBindBase.ctrl:
            keybind1 = LogicalKeyboardKey.control;
            break;
          case KeyBindBase.shift:
            keybind1 = LogicalKeyboardKey.shift;
            break;
          case KeyBindBase.alt:
            keybind1 = LogicalKeyboardKey.alt;
            break;

        }
      });
    });
    getKeybind2().then((value) {
      setState(() {
        keybind2 = LogicalKeyboardKey.findKeyByKeyId(value) ?? LogicalKeyboardKey.enter;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String wrapper(TextEditingController controller, Wrapper wrapper) {
    String content = controller.text;
    if (wrapper.indiv) {
      List<String> lines = content.split('\n');
      for (int j = 0; j < lines.length; j++) {
        String line = lines[j];
        for (int i = 0; i < line.length; i++) {
          if (wrapper.illegals.contains(line[i])) {
            line = line.substring(0, i) + wrapper.ec + line.substring(i);
            i++;
          }
        }
        line = wrapper.ls + line + wrapper.rs;
        for (int i = 0; i < wrapper.replacements.length; i++) {
          line = line.replaceAll(wrapper.replacements[i][0], wrapper.replacements[i][1]);
        }
        lines[j] = line;
      }
      content = lines.join('\n');
    } else {
      for (int i = 0; i < content.length; i++) {
        if (wrapper.illegals.contains(content[i])) {
          content = content.substring(0, i) + wrapper.ec + content.substring(i);
          i++;
        }
      }
      content = wrapper.ls + content + wrapper.rs;
      for (int i = 0; i < wrapper.replacements.length; i++) {
        content = content.replaceAll(wrapper.replacements[i][0], wrapper.replacements[i][1]);
      }
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Wrapping using "${widget.wrapper.name}"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _controller.text));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(keybind1, keybind2): WrapTextIntent(),
                      },
                      child: Actions(actions: <Type, Action<Intent>>{
                        WrapTextIntent: WrapTextAction(_controller, widget.wrapper),
                      }, child: TextField(controller: _controller, maxLines: null, expands: true, autocorrect: false, enableSuggestions: false))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    _controller.text = wrapper(_controller, widget.wrapper);
                  },
                );
              },
              child: Text('Wrap (${keybind1.keyLabel} + ${keybind2.keyLabel})'),
            ),
          ],
        ),
      ),
    );
  }
}

class WrapTextIntent extends Intent {}

class WrapTextAction extends Action<WrapTextIntent> {
  final TextEditingController controller;
  final Wrapper wrapper;

  WrapTextAction(this.controller, this.wrapper);

  @override
  void invoke(WrapTextIntent intent) async {
    controller.text = _WrappingState.wrapper(controller, wrapper);
  }
}
