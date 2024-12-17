import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

/// Control the log level of [DittoLogger]
///
/// Note that this widget will not update if an external source changes the log level
class LogLevelSwitch extends StatefulWidget {
  const LogLevelSwitch({super.key});

  @override
  State<LogLevelSwitch> createState() => _LogLevelSwitchState();
}

class _LogLevelSwitchState extends State<LogLevelSwitch> {
  LogLevel? _current;
  var _loaded = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    final isEnabled = await DittoLogger.getEnabled();
    if (isEnabled) {
      final level = await DittoLogger.getMinimumLogLevel();
      setState(() => _current = level);
    }
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return Container();

    return ListTile(
      title: const Text("Minimum Log Level"),
      trailing: DropdownMenu(
        initialSelection: _current,
        dropdownMenuEntries: [
          _makeEntry(null),
          ...LogLevel.values.map(_makeEntry),
        ],
        onSelected: (level) async {
          if (level != null) {
            await DittoLogger.setEnabled(true);
            await DittoLogger.setMinimumLogLevel(level);
          } else {
            await DittoLogger.setEnabled(false);
          }
          setState(() => _current = level);
        },
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),
    );
  }

  DropdownMenuEntry<LogLevel?> _makeEntry(LogLevel? level) => DropdownMenuEntry(
        value: level,
        label: switch (level) {
          null => "Disabled",
          LogLevel.error => "Error",
          LogLevel.warning => "Warning",
          LogLevel.info => "Info",
          LogLevel.debug => "Debug",
          LogLevel.verbose => "Verbose",
        },
      );
}
