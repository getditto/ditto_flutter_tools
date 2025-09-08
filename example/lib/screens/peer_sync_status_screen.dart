import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:flutter/material.dart';
import 'package:ditto_live/ditto_live.dart';

class PeerSyncStatusScreen extends StatelessWidget {
  final Ditto ditto;

  const PeerSyncStatusScreen({
    super.key,
    required this.ditto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Peer Sync Status")),
      body: PeerSyncStatusView(ditto: ditto),
    );
  }
}