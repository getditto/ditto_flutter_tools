import 'dart:io';

import 'package:ditto_flutter_tools/src/util.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
          try {
            String exportPath;
            
            if (Platform.isIOS) {
              // On iOS, export to the app's Documents directory
              final documentsDir = await getApplicationDocumentsDirectory();
              exportPath = p.join(documentsDir.path, "ditto_log.txt");
            } else {
              // On Android, macOS, and other platforms, let user choose directory
              final dir = await FilePicker.platform.getDirectoryPath();
              if (dir == null) return;
              exportPath = p.join(dir, "ditto_log.txt");
            }
            
            await DittoLogger.exportLogs(exportPath);
            
            if (Platform.isIOS) {
              _showSnackbar("Logs exported to Files app\n(Check in Files > On My iPhone > Example)");
            } else {
              _showSnackbar("Logs exported to $exportPath");
            }
          } catch (e) {
            _showSnackbar("Export failed: ${e.toString()}");
          }
        },
      );

  Widget get _exportData => OutlinedButton.icon(
        label: const Text("Export Data Directory"),
        icon: const Icon(Icons.folder),
        onPressed: () async {
          try {
            String? exportPath;
            
            if (Platform.isIOS) {
              // On iOS, export to the app's Documents directory which is accessible via Files app
              final documentsDir = await getApplicationDocumentsDirectory();
              exportPath = documentsDir.path;
            } else {
              // On Android, macOS, and other platforms, let user choose directory
              exportPath = await FilePicker.platform.getDirectoryPath();
              if (exportPath == null) return;
            }
            
            final actualExportPath = copyDir(widget.ditto.persistenceDirectory, exportPath);
            
            if (Platform.isIOS) {
              final exportDirName = p.basename(actualExportPath);
              _showSnackbar("Data exported to Files app in: $exportDirName\n(Check in Files > On My iPhone > Example)");
            } else {
              _showSnackbar("Data exported to $actualExportPath");
            }
          } catch (e) {
            _showSnackbar("Export failed: ${e.toString()}");
          }
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
