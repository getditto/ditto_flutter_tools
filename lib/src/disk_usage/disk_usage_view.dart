import 'package:ditto_flutter_tools/src/util.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../cross_platform/cross_platform.dart';

class DiskUsageView extends StatefulWidget {
  final Ditto ditto;
  const DiskUsageView({super.key, required this.ditto});

  @override
  State<DiskUsageView> createState() => _DiskUsageViewState();
}

class _DiskUsageViewState extends State<DiskUsageView> {
  late final _paths = directorySizeSummary(
    widget.ditto.persistenceDirectory,
  );

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          _buttonBar,
          const Divider(),
          ..._paths.map(
            (pair) => ListTile(
              title: Text(pair.$1),
              trailing: Text(humanReadableBytes(pair.$2)),
            ),
          )
        ],
      );

  Widget get _buttonBar => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(child: _exportLogs),
            const SizedBox(width: 16),
            Expanded(child: _exportData),
          ],
        ),
      );

  Widget get _exportLogs => OutlinedButton.icon(
        label: const Text("Export Logs"),
        icon: const Icon(Icons.bug_report),
        onPressed: () async {
          // i would use "saveFile" but for some reason it crashes
          final dir = await FilePicker.platform.getDirectoryPath();
          if (dir == null) return;
          final path = p.join(dir, "ditto_log.txt");
          await DittoLogger.exportLogs(path);
          _showSnackbar("Logs exported to $path");
        },
      );

  Widget get _exportData => OutlinedButton.icon(
        label: const Text("Export Data Directory"),
        icon: const Icon(Icons.folder),
        onPressed: () async {
          final path = await FilePicker.platform.getDirectoryPath();
          if (path == null) return;
          copyDir(widget.ditto.persistenceDirectory, path);
          _showSnackbar("Data exported to $path");
        },
      );

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
