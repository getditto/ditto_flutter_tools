import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

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
    final file = XFile.fromData(
      Uint8List.fromList(content.codeUnits),
      name: 'ditto_query_results_$timestamp.json',
      mimeType: 'application/json',
    );

    return await Share.shareXFiles([file],
        subject: 'Ditto Query Results',
        text: 'Query results from Ditto database');
  }

  static String getShareStatusMessage(ShareResultStatus status) {
    switch (status) {
      case ShareResultStatus.success:
        return "Results shared successfully!";
      case ShareResultStatus.dismissed:
        return "Sharing was cancelled";
      case ShareResultStatus.unavailable:
        // On web, "unavailable" actually means the file was downloaded
        if (kIsWeb) {
          return "Results downloaded successfully!";
        }
        return "Sharing is not available on this platform";
    }
  }
}
