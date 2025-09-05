import 'dart:async';

import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'peer_sync_status.dart';

class PeerSyncStatusView extends StatefulWidget {
  final Ditto ditto;

  const PeerSyncStatusView({super.key, required this.ditto});

  @override
  State<PeerSyncStatusView> createState() => _PeerSyncStatusViewState();
}

class _PeerSyncStatusViewState extends State<PeerSyncStatusView> {
  final _syncStatusStreamController = StreamController<QueryResult>.broadcast();
  StoreObserver? _syncStatusObserver;
  QueryResult? _latestSyncStatusResult;
  StreamSubscription? _observerSubscription;
  bool _isStrictMode = false;

  Stream<QueryResult> get _syncStatusStream async* {
    if (_latestSyncStatusResult != null) {
      yield _latestSyncStatusResult!;
    }
    yield* _syncStatusStreamController.stream;
  }

  @override
  void initState() {
    super.initState();
    _initializeObserver();
  }

  Future<void> _initializeObserver() async {
    // Check DQL strict mode first
    await _checkDqlStrictMode();
    _registerObserver();
  }

  Future<void> _checkDqlStrictMode() async {
    try {
      final result = await widget.ditto.store.execute("SHOW DQL_STRICT_MODE");
      if (result.items.isNotEmpty) {
        final item = result.items.first;
        final strictModeValue = item.value["dql_strict_mode"];

        // Cast to bool and validate
        if (strictModeValue is bool) {
          _isStrictMode = strictModeValue;
        } else {
          _isStrictMode = true;
        }
      }
    } catch (e) {
      // If the query fails, assume non-strict mode (default)
      _isStrictMode = false;
    }
  }

  void _registerObserver() {
    final query = _isStrictMode
        ? "SELECT * FROM COLLECTION system:data_sync_info (documents MAP) ORDER BY sync_session_status, last_update_received_time DESC"
        : "SELECT * FROM system:data_sync_info ORDER BY sync_session_status, last_update_received_time DESC";

    _syncStatusObserver = widget.ditto.store.registerObserver(query);

    _observerSubscription = _syncStatusObserver!.changes.listen((result) {
      // Only process if the widget is still mounted and stream is not closed
      if (mounted && !_syncStatusStreamController.isClosed) {
        _latestSyncStatusResult = result;
        _syncStatusStreamController.add(result);
      }
    });
  }

  @override
  void dispose() {
    // Cancel the subscription first to stop incoming events
    _observerSubscription?.cancel();
    _observerSubscription = null;
    
    // Cancel the observer
    _syncStatusObserver?.cancel();
    _syncStatusObserver = null;
    
    // Close the stream controller last
    if (!_syncStatusStreamController.isClosed) {
      _syncStatusStreamController.close();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueryResult>(
      stream: _syncStatusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading sync status...'),
              ],
            ),
          );
        }

        final result = snapshot.data!;
        final syncStatuses = result.items
            .map((item) => SyncStatus.fromJson(item.value))
            .toList();

        final connectedPeers =
            syncStatuses.where((status) => status.isConnected).toList();

        final notConnectedPeers =
            syncStatuses.where((status) => !status.isConnected).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (connectedPeers.isNotEmpty) ...[
              _buildSectionHeader('Connected Peers', context),
              if (connectedPeers.first.lastUpdateReceivedTime != null)
                Text(
                  'Last updated: ${_formatLastUpdate(connectedPeers.first.lastUpdateReceivedTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              const SizedBox(height: 16),
              ...connectedPeers.map((peer) => _buildPeerCard(peer, context)),
            ],
            if (notConnectedPeers.isNotEmpty) ...[
              if (connectedPeers.isNotEmpty) const SizedBox(height: 24),
              _buildSectionHeader('Not Connected', context),
              const SizedBox(height: 16),
              ...notConnectedPeers.map((peer) => _buildPeerCard(peer, context)),
            ],
            if (connectedPeers.isEmpty && notConnectedPeers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No peer sync information available'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildPeerCard(SyncStatus syncStatus, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syncStatus.peerType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        syncStatus.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: syncStatus.isConnected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      syncStatus.isConnected ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        color: syncStatus.isConnected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (syncStatus.hasSyncedCommit) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Synced to local database commit: ${syncStatus.syncedUpToLocalCommitId}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (syncStatus.hasLastUpdateTime) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last update: ${_formatTimestamp(syncStatus.lastUpdateReceivedTime!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('MMM d, y h:mm a').format(date);
    }
  }

  String _formatLastUpdate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    return _formatTimestamp(timestamp);
  }
}
