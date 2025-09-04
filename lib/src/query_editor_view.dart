import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _pageController = TextEditingController();
  bool _isExecuting = false;
  List<String> _allResults = [];
  List<String> _paginatedResults = [];
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _itemsPerPage = 10;

  // Computed properties
  int get _totalPages =>
      _allResults.isEmpty ? 0 : ((_allResults.length - 1) ~/ _itemsPerPage) + 1;
  int get _startIndex => (_currentPage - 1) * _itemsPerPage;
  int get _endIndex =>
      (_startIndex + _itemsPerPage).clamp(0, _allResults.length);

  @override
  void dispose() {
    _queryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updatePaginatedResults() {
    if (_allResults.isEmpty) {
      _paginatedResults = [];
      return;
    }

    // Ensure current page is valid
    final maxPage = _totalPages;
    if (_currentPage > maxPage) {
      _currentPage = maxPage;
    }

    final start = _startIndex;
    final end = _endIndex;
    _paginatedResults = _allResults.sublist(start, end);
    _pageController.text = _currentPage.toString();
  }

  void _goToPage(int page) {
    final clampedPage = page.clamp(1, _totalPages);
    if (clampedPage != _currentPage) {
      setState(() {
        _currentPage = clampedPage;
        _updatePaginatedResults();
      });
    }
  }

  void _previousPage() => _goToPage(_currentPage - 1);
  void _nextPage() => _goToPage(_currentPage + 1);

  void _changeItemsPerPage(int newItemsPerPage) {
    setState(() {
      _itemsPerPage = newItemsPerPage;
      _currentPage = 1;
      _updatePaginatedResults();
    });
  }

  void _handlePageInput(String value) {
    final pageNum = int.tryParse(value);
    if (pageNum != null && pageNum >= 1 && pageNum <= _totalPages) {
      _goToPage(pageNum);
    } else {
      // Invalid input - revert to current page
      _pageController.text = _currentPage.toString();
    }
  }

  Future<void> _executeQuery() async {
    if (_queryController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a DQL statement';
        _allResults = [];
        _paginatedResults = [];
      });
      return;
    }

    // Immediately update UI to show spinner
    setState(() {
      _isExecuting = true;
      _errorMessage = null;
      _allResults = [];
      _paginatedResults = [];
    });

    // Allow UI to update by yielding control
    await Future.delayed(Duration.zero);

    try {
      final query = _queryController.text.trim();

      // Execute the query (this is the potentially long-running operation)
      final result = await widget.ditto.store.execute(query);

      // Process results asynchronously to avoid blocking UI
      final resultStrings = await _processQueryResults(result);

      // Update UI with results if still mounted
      if (mounted) {
        setState(() {
          _allResults = resultStrings;
          _currentPage = 1;
          _updatePaginatedResults();
          _isExecuting = false;
        });
      }
    } catch (e) {
      // Update UI with error if still mounted
      if (mounted) {
        setState(() {
          _errorMessage = 'Error executing query: ${e.toString()}';
          _allResults = [];
          _paginatedResults = [];
          _currentPage = 1;
          _isExecuting = false;
        });
      }
    }
  }

  Future<List<String>> _processQueryResults(dynamic result) async {
    final List<String> resultStrings = [];

    // Check if it's a SELECT query (returns QueryResult with items)
    if (result.items.isNotEmpty) {
      // Process results in chunks to avoid blocking UI thread
      final items = result.items.toList();
      const chunkSize = 50; // Process 50 items at a time
      
      for (int i = 0; i < items.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, items.length);
        final chunk = items.sublist(i, end);
        
        // Process chunk of items
        for (final item in chunk) {
          // Access the actual document data using the value property
          final documentData = item.value;
          resultStrings.add(documentData.toString());
        }
        
        // Yield control back to UI thread after each chunk
        if (i + chunkSize < items.length) {
          await Future.delayed(Duration.zero);
        }
      }
      
      if (resultStrings.isEmpty) {
        resultStrings.add('No results found');
      }
    } else {
      // This is likely a mutation query (INSERT/UPDATE/DELETE)
      final mutatedIds = result.mutatedDocumentIDs;
      if (mutatedIds.isNotEmpty) {
        resultStrings.add('Mutated Documents:');
        for (final docId in mutatedIds) {
          resultStrings.add('  Document ID: ${docId.toString()}');
        }
      } else if (result.items.isEmpty) {
        // Query executed but no items returned or mutated
        resultStrings.add('Query executed successfully (no results)');
      }
    }

    return resultStrings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Editor'),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          // Query Input Section
          Container(
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
                  style: const TextStyle(fontFamily: 'monospace'),
                  enabled: !_isExecuting,
                ),
              ],
            ),
          ),

          const Divider(),

          // Results Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Results:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(width: 8),
                      if (_allResults.isNotEmpty) ...[
                        Text(
                          '${_allResults.length} total ${_allResults.length == 1 ? "item" : "items"}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (_totalPages > 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(showing ${_startIndex + 1}-$_endIndex)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isExecuting)
                    const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 32),
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Executing query...'),
                        ],
                      ),
                    )
                  else if (_allResults.isEmpty)
                    Center(
                      child: Text(
                        'No results yet. Enter a query and press the play button.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    // Results List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _paginatedResults.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final result = _paginatedResults[index];
                            final isHeader =
                                result.contains('Mutated Documents:') ||
                                    result.contains('Transaction ID:');

                            return Padding(
                              padding: EdgeInsets.only(
                                left: result.startsWith('  ') ? 16.0 : 0,
                                top: 4,
                                bottom: 4,
                              ),
                              child: SelectableText(
                                result,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: isHeader
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isHeader
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Pagination Controls
                  if (_totalPages > 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 400;

                          if (isNarrow) {
                            // Mobile layout - stack controls vertically
                            return Column(
                              children: [
                                // Top row: page navigation
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _currentPage > 1
                                          ? _previousPage
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                      tooltip: 'Previous page',
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _pageController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 4),
                                          isDense: true,
                                        ),
                                        onSubmitted: _handlePageInput,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'of $_totalPages',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _currentPage < _totalPages
                                          ? _nextPage
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                      tooltip: 'Next page',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Bottom row: items per page
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Show:',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<int>(
                                      value: _itemsPerPage,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      underline: Container(
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 10, child: Text('10')),
                                        DropdownMenuItem(
                                            value: 25, child: Text('25')),
                                        DropdownMenuItem(
                                            value: 50, child: Text('50')),
                                        DropdownMenuItem(
                                            value: 100, child: Text('100')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          _changeItemsPerPage(value);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'per page',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Desktop layout - single row
                            return Row(
                              children: [
                                // Previous button
                                IconButton(
                                  onPressed:
                                      _currentPage > 1 ? _previousPage : null,
                                  icon: const Icon(Icons.chevron_left),
                                  tooltip: 'Previous page',
                                ),

                                // Page input
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _pageController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      isDense: true,
                                    ),
                                    onSubmitted: _handlePageInput,
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Text(
                                  'of $_totalPages',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                // Next button
                                IconButton(
                                  onPressed: _currentPage < _totalPages
                                      ? _nextPage
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  tooltip: 'Next page',
                                ),

                                const Spacer(),

                                // Items per page selector
                                Text(
                                  'Show:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: _itemsPerPage,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 10, child: Text('10')),
                                    DropdownMenuItem(
                                        value: 25, child: Text('25')),
                                    DropdownMenuItem(
                                        value: 50, child: Text('50')),
                                    DropdownMenuItem(
                                        value: 100, child: Text('100')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _changeItemsPerPage(value);
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'per page',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
