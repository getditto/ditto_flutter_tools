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
    this.idleTimeoutInterval = const Duration(seconds: 5),
    this.autoRefreshInterval = const Duration(seconds: 5),
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
    _autoUpdateSubscription.cancel();
    _helper.removeListener(_listener);
    _helper = SyncStatusHelper(
      ditto: widget.ditto,
      subscriptions: widget.subscriptions,
      idleTimeoutInterval: widget.idleTimeoutInterval,
    );
    _helper.addListener(_listener);
    _autoUpdateSubscription = Stream.periodic(widget.autoRefreshInterval)
        .listen((_) => setState(() {}));

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
              final lastUpdated = switch (_helper.lastUpdatedAt(sub)) {
                DateTime d => timeago.format(d),
                null => "Never",
              };

              return ListTile(
                title: Text(sub.queryString),
                subtitle: Text("Last updated: $lastUpdated"),
                trailing: Text(_helper.statusFor(sub).toString()),
              );
            },
          ),
        ],
      );

  Widget get _overallStatus => ListTile(
        title: const Text("Sync Status"),
        subtitle: Text("${_helper.subscriptions.length} Subscriptions"),
        trailing: Text(_helper.overallStatus.toString()),
      );
}
