import 'package:ditto_flutter_tools/src/sync_status_helper.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncStatusView extends StatefulWidget {
  final Ditto ditto;
  final List<SyncSubscription> subscriptions;
  final Duration idleTimeoutInterval;

  /// This widget will automatically refresh itself periodically to keep "time ago" messages accurate
  final Duration autoRefreshInterval;

  const SyncStatusView({
    super.key,
    required this.ditto,
    required this.subscriptions,
    this.idleTimeoutInterval = const Duration(seconds: 1),
    this.autoRefreshInterval = const Duration(seconds: 1),
  });

  @override
  State<SyncStatusView> createState() => _SyncStatusViewState();
}

class _SyncStatusViewState extends State<SyncStatusView> {
  late var _helper = SyncStatusHelper(
    ditto: widget.ditto,
    subscriptions: widget.subscriptions,
    idleTimeoutInterval: widget.idleTimeoutInterval,
  );

  late var _autoUpdateSubscription = Stream.periodic(widget.autoRefreshInterval)
      .listen((_) => setState(() {}));

  @override
  void initState() {
    super.initState();

    _helper.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant SyncStatusView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoRefreshInterval != oldWidget.autoRefreshInterval) {
      _autoUpdateSubscription.cancel();
      _autoUpdateSubscription = Stream.periodic(widget.autoRefreshInterval)
          .listen((_) => setState(() {}));
    }

    _helper.dispose();
    _helper = SyncStatusHelper(
      ditto: widget.ditto,
      subscriptions: widget.subscriptions,
      idleTimeoutInterval: widget.idleTimeoutInterval,
    );
    _helper.addListener(_listener);

    setState(() {});
  }

  @override
  void dispose() {
    _helper.dispose();
    _autoUpdateSubscription.cancel();
    super.dispose();
  }

  void _listener() => setState(() {});

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          _overallStatus,
          const Divider(),
          if (_helper.subscriptions.isEmpty)
            const ListTile(title: Text("No subscriptions tracked")),
          ..._helper.subscriptions.map(
            (sub) {
              return ListTile(
                title: Text(sub.queryString),
                subtitle: Text(
                  "Last updated: ${_date(_helper.lastUpdatedAt(sub))}",
                ),
                leading: _statusIcon(_helper.statusFor(sub), context),
              );
            },
          ),
        ],
      );

  Widget get _overallStatus => ExpansionTile(
        title: const Text("Sync Status"),
        subtitle: Text("${_helper.subscriptions.length} Subscriptions"),
        leading: _statusIcon(_helper.overallStatus, context),
        children: [
          ListTile(
            title: Text("Connected: ${_helper.isConnected}"),
            subtitle: _helper.isConnected
                ? Text(
                    "Connection established: ${_date(_helper.becameConnectedAt)}")
                : Text(
                    "Connection lost: ${_date(_helper.becameDisconnectedAt)}"),
          )
        ],
      );
}

String _date(DateTime? date) => switch (date) {
      DateTime d => timeago.format(d),
      null => "Never",
    };

Widget _statusIcon(SyncStatus status, BuildContext context) => switch (status) {
      SyncStatus.disconnected => Tooltip(
          message: "Disconnected",
          child: Icon(
            Icons.sync_disabled,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      SyncStatus.connectedSyncing => Tooltip(
          message: "Connected (Syncing)",
          child: Icon(
            Icons.sync,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      SyncStatus.connectedIdle => Tooltip(
          message: "Connected (Idle)",
          child: Icon(
            Icons.hourglass_empty,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
        ),
    };
