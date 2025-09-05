import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

import 'query_result_exporter.dart';

class QueryEditorView extends StatefulWidget {
  final Ditto ditto;

  const QueryEditorView({
    super.key,
    required this.ditto,
  });

  @override
  State<QueryEditorView> createState() => _QueryEditorViewState();
}

class _QueryEditorViewState extends State<QueryEditorView> {
  final TextEditingController _queryController = TextEditingController();
  bool _isExecuting = false;
  List<QueryResultItem> _queryItems = [];
  List<Map<String, dynamic>> _mutationResults = [];
  String? _errorMessage;
  QueryResult? _rawQueryResult;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }


  Future<void> _executeQuery() async {
    if (_queryController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a DQL statement';
        _queryItems = [];
        _mutationResults = [];
      });
      return;
    }

    // Immediately update UI to show spinner
    setState(() {
      _isExecuting = true;
      _errorMessage = null;
      _rawQueryResult = null;
      _queryItems = [];
      _mutationResults = [];
    });

    // Allow UI to update by yielding control
    await Future.delayed(Duration.zero);

    try {
      final query = _queryController.text.trim();

      // Execute the query (this is the potentially long-running operation)
      final result = await widget.ditto.store.execute(query);

      // Process results asynchronously to avoid blocking UI
      await _processQueryResults(result);

      // Update UI with results if still mounted
      if (mounted) {
        setState(() {
          _rawQueryResult = result;
          _isExecuting = false;
        });
      }
    } catch (e) {
      // Update UI with error if still mounted
      if (mounted) {
        setState(() {
          _errorMessage = 'Error executing query: ${e.toString()}';
          _rawQueryResult = null;
          _queryItems = [];
          _mutationResults = [];
          _isExecuting = false;
        });
      }
    }
  }

  Future<void> _processQueryResults(QueryResult result) async {
    // Check if it's a SELECT query (returns QueryResult with items)
    if (result.items.isNotEmpty) {
      // Process results in chunks to avoid blocking UI thread
      final items = result.items.toList();
      const chunkSize = 50; // Process 50 items at a time

      final processedItems = <QueryResultItem>[];
      for (int i = 0; i < items.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, items.length);
        final chunk = items.sublist(i, end);
        processedItems.addAll(chunk);

        // Yield control back to UI thread after each chunk
        if (i + chunkSize < items.length) {
          await Future.delayed(Duration.zero);
        }
      }

      setState(() {
        _queryItems = processedItems;
        _mutationResults = [];
      });
    } else {
      // This is likely a mutation query (INSERT/UPDATE/DELETE)
      final mutatedIds = result.mutatedDocumentIDs;
      final mutationInfo = <Map<String, dynamic>>[];
      
      if (mutatedIds.isNotEmpty) {
        for (final docId in mutatedIds) {
          mutationInfo.add({'type': 'mutation', 'id': docId.toString()});
        }
      } else if (result.items.isEmpty) {
        // Query executed but no items returned or mutated
        mutationInfo.add({'type': 'success', 'message': 'Query executed successfully (no results)'});
      }

      setState(() {
        _queryItems = [];
        _mutationResults = mutationInfo;
      });
    }
  }

  bool _hasActualResults() {
    return _rawQueryResult != null && _rawQueryResult!.items.isNotEmpty;
  }

  Future<void> _shareResults() async {
    if (!_hasActualResults()) return;

    try {
      final result = await QueryResultExporter.shareResults(
        _rawQueryResult,
        onStatusUpdate: _showSnackbar,
      );

      final message = QueryResultExporter.getShareStatusMessage(result.status);
      _showSnackbar(message);
    } catch (e) {
      _showSnackbar(e.toString());
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget get _queryInputSection => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter DQL Statement:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _queryController,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., SELECT * FROM collection',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              enabled: !_isExecuting,
            ),
          ],
        ),
      );

  List<Widget> get _appBarActions => [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share Results',
          onPressed: _hasActualResults() ? _shareResults : null,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _isExecuting
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Execute Query',
                  onPressed: _executeQuery,
                ),
        ),
      ];

  Widget get _errorDisplay => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );

  Widget get _loadingDisplay => const Center(
        child: Column(
          children: [
            SizedBox(height: 32),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Executing query...'),
          ],
        ),
      );

  Widget get _emptyResultsDisplay => Center(
        child: Text(
          'No results yet. Enter a query and press the play button.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      );

  Widget get _resultsHeader => Row(
        children: [
          Text(
            'Results:',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 8),
          if (_queryItems.isNotEmpty) ...[
            Text(
              '${_queryItems.length} total ${_queryItems.length == 1 ? "item" : "items"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else if (_mutationResults.isNotEmpty) ...[
            Text(
              'Mutation result',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      );

  Widget get _resultsList => Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _queryItems.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _queryItems.length,
                  itemBuilder: (context, index) {
                    final item = _queryItems[index];
                    final documentData = item.value;
                    final docId = documentData['_id']?.toString() ?? 'Document ${index + 1}';
                    final jsonString = documentData.toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          docId,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        subtitle: Text(
                          jsonString,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SelectableText(
                              jsonString,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : _mutationResults.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _mutationResults.length,
                      itemBuilder: (context, index) {
                        final result = _mutationResults[index];
                        if (result['type'] == 'mutation') {
                          return ListTile(
                            leading: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text('Document ID: ${result['id']}'),
                          );
                        } else {
                          return ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(result['message']),
                          );
                        }
                      },
                    )
                  : const SizedBox.shrink(),
        ),
      );


  Widget get _resultsSection => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _resultsHeader,
              const SizedBox(height: 8),
              if (_errorMessage != null)
                _errorDisplay
              else if (_isExecuting)
                _loadingDisplay
              else if (_queryItems.isEmpty && _mutationResults.isEmpty)
                _emptyResultsDisplay
              else
                _resultsList,
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Editor'),
        actions: _appBarActions,
      ),
      body: Column(
        children: [
          _queryInputSection,
          const Divider(),
          _resultsSection,
        ],
      ),
    );
  }
}
