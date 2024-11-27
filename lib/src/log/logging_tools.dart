import 'dart:math';

import 'package:ditto_flutter_tools/src/cross_platform/cross_platform.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../util.dart';
import 'log_level_switch.dart';

class LoggingTools extends StatelessWidget {
  const LoggingTools({super.key});

  @override
  Widget build(BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text("Export Logs")),
          SaveOrShareLogsButtons(),
          Divider(),
          LogLevelSwitch(),
        ],
      );
}

class SaveOrShareLogsButtons extends StatelessWidget {
  const SaveOrShareLogsButtons({super.key});

  @override
  Widget build(BuildContext context) => const ButtonBar(
        children: [
          SaveLogsButton(),
          ShareLogsButton(),
        ],
      );
}

class SaveLogsButton extends StatelessWidget {
  const SaveLogsButton({super.key});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        label: const Text("Save"),
        icon: const Icon(Icons.save),
        onPressed: () => SaveLogsButton.saveLogs(context),
      );

  static Future<void> saveLogs(
    BuildContext context, {
    /// Whether to show a confirmation snackbar
    bool snackbar = true,
  }) async {
    // i would use "saveFile" but for some reason it crashes
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    final path = p.join(dir, "ditto_log.txt");
    await DittoLogger.exportLogs(path);
    if (context.mounted) {
      if (snackbar) showSnackbar(context, "Logs exported to $path");
    }
  }
}

class ShareLogsButton extends StatelessWidget {
  const ShareLogsButton({super.key});

  static Future<void> shareLogs(
    BuildContext context, {
    /// Whether to show a confirmation snackbar
    bool snackbar = true,
  }) async {
    final name = "ditto-log-${Random().nextInt(1 << 32).toString()}.txt";
    final path = p.join(await tempDir(), name);
    await DittoLogger.exportLogs(path);
    final result = await Share.shareXFiles([XFile(path)]);
    final message = switch (result.status) {
      ShareResultStatus.success => "Logs shared successfully",
      ShareResultStatus.unavailable => "Sharing unavailable",
      ShareResultStatus.dismissed => null,
    };

    if (context.mounted) {
      if (snackbar && message != null) {
        showSnackbar(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        label: const Text("Share"),
        icon: const Icon(Icons.share),
        onPressed: () => ShareLogsButton.shareLogs(context),
      );
}
