import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

class PresenceView extends StatefulWidget {
  final Ditto ditto;
  const PresenceView({super.key, required this.ditto});

  @override
  State<PresenceView> createState() => _PresenceViewState();
}

class _PresenceViewState extends State<PresenceView> {
  PresenceObserver? _observer;
  PresenceGraph? _graph;

  @override
  void initState() {
    super.initState();

    _observer = widget.ditto.presence
        .observe((graph) => setState(() => _graph = graph));
  }

  @override
  void dispose() {
    super.dispose();

    _observer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    final graph = _graph;

    if (graph == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        const ListTile(title: Text("Local Peer")),
        _PeerView(graph.localPeer),
        const Divider(),
        const ListTile(title: Text("Remote Peers")),
        ...graph.remotePeers.map(_PeerView.new)
      ],
    );
  }
}

class _PeerView extends StatelessWidget {
  final Peer peer;
  const _PeerView(this.peer);

  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: Text(peer.deviceName),
        subtitle: Text("Peer Key: ${peer.peerKeyString}"),
        leading: peer.isConnectedToDittoCloud
            ? const Icon(Icons.cloud)
            : const Icon(Icons.cloud_off),
        children: [
          if (peer.connections.isEmpty)
            const ListTile(title: Text("No connected devices")),
          ...peer.connections.map(
            (conn) => ListTile(
              title: Text("${conn.peerKeyString1} <=> ${conn.peerKeyString2}"),
              subtitle: Text(conn.connectionType.toString()),
            ),
          )
        ],
      );
}
