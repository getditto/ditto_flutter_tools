import 'package:ditto_live/ditto_live.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:proper_filesize/proper_filesize.dart';

import '../cross_platform/cross_platform.dart';
import '../util.dart';

class DiskUsage extends StatefulWidget {
  static Future<void> show(BuildContext context, Ditto ditto) => showDialog(
        context: context,
        builder: (context) => DiskUsage(ditto: ditto),
      );

  final Ditto ditto;
  const DiskUsage({super.key, required this.ditto});

  @override
  State<DiskUsage> createState() => _DiskUsageState();
}

class _DiskUsageState extends State<DiskUsage> {
  late final _paths = directorySizeSummary(
    widget.ditto.persistenceDirectoryString,
  );

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: const Text("Ditto Disk Usage"),
        children: [
          ..._paths.map(
            (pair) => ListTile(
              title: Text(pair.$1),
              trailing: Text(_humanReadableBytes(pair.$2)),
            ),
          )
        ],
      );

  Widget get _exportData => OutlinedButton.icon(
        label: const Text("Export Data Directory"),
        icon: const Icon(Icons.folder),
        onPressed: () async {
          final path = await FilePicker.platform.getDirectoryPath();
          if (path == null) return;
          copyDir(widget.ditto.persistenceDirectoryString, path);

          if (mounted) {
            Navigator.pop(context);
            showSnackbar(context, "Data exported to $path");
          }
        },
      );
}

String _humanReadableBytes(int bytes) =>
    ProperFilesize.generateHumanReadableFilesize(
      bytes,
      base: Bases.Metric,
      decimals: 0,
    );
