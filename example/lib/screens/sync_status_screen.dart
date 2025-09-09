import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:flutter/material.dart';
import 'package:ditto_live/ditto_live.dart';

class SyncStatusScreen extends StatelessWidget {
  final Ditto ditto;
  final List<SyncSubscription> subscriptions;

  const SyncStatusScreen({
    super.key,
    required this.ditto,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sync Status")),
      body: SyncStatusView(
        ditto: ditto,
        subscriptions: subscriptions,
      ),
    );
  }
}