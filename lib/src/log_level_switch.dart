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
  LogLevel? _current =
      DittoLogger.isEnabled ? DittoLogger.minimumLogLevel : null;

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text("Minimum Log Level"),
        trailing: DropdownMenu(
          initialSelection: _current,
          dropdownMenuEntries: [
            _makeEntry(null),
            ...LogLevel.values.map(_makeEntry),
          ],
          onSelected: (level) async {
            if (level != null) {
              DittoLogger.isEnabled = true;
              DittoLogger.minimumLogLevel = level;
            } else {
              DittoLogger.isEnabled = false;
            }
            setState(() => _current = level);
          },
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
          ),
        ),
      );

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
