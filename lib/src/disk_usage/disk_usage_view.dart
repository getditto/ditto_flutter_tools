import 'package:ditto_flutter_tools/src/util.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
            _showSnackbar("Preparing logs for sharing...");
            
            // Create temporary log file with unique name to avoid conflicts
            final tempDir = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final tempLogPath = p.join(tempDir.path, "ditto_log_$timestamp.txt");
            
            try {
              // Export logs to temporary file
              try {
                await DittoLogger.exportLogs(tempLogPath);
              } catch (e) {
                throw Exception('Failed to export logs: ${e.toString()}');
              }
              
              // Verify log file was created
              final logFile = XFile(tempLogPath);
              if (!await logFile.length().then((len) => len > 0).catchError((_) => false)) {
                throw Exception('Log file is empty or could not be created');
              }
              
              // Share the log file using native share dialog
              final result = await Share.shareXFiles(
                [logFile],
                subject: 'Ditto Logs Export',
                text: 'Ditto application logs'
              );
              
              if (result.status == ShareResultStatus.success) {
                _showSnackbar("Logs shared successfully!");
              } else if (result.status == ShareResultStatus.dismissed) {
                _showSnackbar("Sharing was cancelled");
              } else if (result.status == ShareResultStatus.unavailable) {
                _showSnackbar("Sharing is not available on this platform");
              } else {
                _showSnackbar("Sharing failed: ${result.status}");
              }
            } finally {
              // Always clean up the temporary log file, regardless of sharing result
              try {
                await deleteTemporaryFile(tempLogPath);
              } catch (e) {
                // Ignore cleanup errors, but log them in debug mode
                debugPrint("Failed to clean up temporary log file: $e");
              }
            }
          } catch (e) {
            _showSnackbar("Log export failed: ${e.toString()}");
          }
        },
      );

  Widget get _exportData => OutlinedButton.icon(
        label: const Text("Export Data Directory"),
        icon: const Icon(Icons.folder),
        onPressed: () async {
          try {
            _showSnackbar("Creating database export... This may take a moment.");
            
            // Create temporary ZIP file of database directory
            String tempZipPath = '';
            
            try {
              tempZipPath = await createTempZipForSharing(widget.ditto.persistenceDirectory);
              
              // Verify ZIP file exists and has content
              final zipFile = XFile(tempZipPath);
              final zipSize = await zipFile.length().catchError((_) => 0);
              if (zipSize == 0) {
                throw Exception('Database archive is empty');
              }
              
              // Share the ZIP file using native share dialog
              final result = await Share.shareXFiles(
                [zipFile],
                subject: 'Ditto Database Export',
                text: 'Ditto database directory export (includes all data and lock files)'
              );
              
              if (result.status == ShareResultStatus.success) {
                _showSnackbar("Database export shared successfully!");
              } else if (result.status == ShareResultStatus.dismissed) {
                _showSnackbar("Sharing was cancelled");
              } else if (result.status == ShareResultStatus.unavailable) {
                _showSnackbar("Sharing is not available on this platform");
              } else {
                _showSnackbar("Sharing failed: ${result.status}");
              }
            } catch (e) {
              throw Exception('Failed to create or share database export: ${e.toString()}');
            } finally {
              // Always clean up temporary ZIP file, regardless of sharing result
              if (tempZipPath.isNotEmpty) {
                try {
                  await deleteTemporaryFile(tempZipPath);
                } catch (e) {
                  // Ignore cleanup errors, but log them in debug mode
                  debugPrint("Failed to clean up temporary ZIP file: $e");
                }
              }
            }
          } catch (e) {
            _showSnackbar("Database export failed: ${e.toString()}");
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
