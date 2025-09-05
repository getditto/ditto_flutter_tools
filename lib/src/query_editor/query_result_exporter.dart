import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../cross_platform/cross_platform.dart';

class QueryResultExporter {
  static Future<ShareResult> shareResults(
    QueryResult? rawQueryResult, {
    Function(String)? onStatusUpdate,
  }) async {
    if (rawQueryResult == null || rawQueryResult.items.isEmpty) {
      throw Exception('No actual results to share');
    }

    try {
      onStatusUpdate?.call("Preparing results for sharing...");

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Extract and convert query results to JSON string
      final jsonContent = rawQueryResult.items
          .map((item) => item.value.toString())
          .join('\n');

      if (kIsWeb) {
        return await _shareOnWeb(jsonContent, timestamp);
      } else {
        return await _shareOnMobile(jsonContent, timestamp);
      }
    } catch (e) {
      throw Exception("Results sharing failed: ${e.toString()}");
    }
  }

  static Future<ShareResult> _shareOnWeb(String content, int timestamp) async {
    final file = XFile.fromData(
      Uint8List.fromList(content.codeUnits),
      name: 'ditto_query_results_$timestamp.json',
      mimeType: 'application/json',
    );

    return await Share.shareXFiles([file],
        subject: 'Ditto Query Results',
        text: 'Query results from Ditto database');
  }

  static Future<ShareResult> _shareOnMobile(
      String content, int timestamp) async {
    final tempDir = await getTemporaryDirectory();
    final tempResultsPath =
        p.join(tempDir.path, "ditto_query_results_$timestamp.json");

    try {
      final file = XFile.fromData(
        Uint8List.fromList(content.codeUnits),
        name: 'ditto_query_results_$timestamp.json',
        mimeType: 'application/json',
      );

      final result = await Share.shareXFiles([file],
          subject: 'Ditto Query Results',
          text: 'Query results from Ditto database');

      return result;
    } finally {
      // Clean up temporary file if it was created on disk
      try {
        await deleteTemporaryFile(tempResultsPath);
      } catch (e) {
        // Ignore cleanup errors for in-memory XFile
      }
    }
  }

  static String getShareStatusMessage(ShareResultStatus status) {
    switch (status) {
      case ShareResultStatus.success:
        return "Results shared successfully!";
      case ShareResultStatus.dismissed:
        return "Sharing was cancelled";
      case ShareResultStatus.unavailable:
        return "Sharing is not available on this platform";
    }
  }
}
