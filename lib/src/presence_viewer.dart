import 'dart:convert';

import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

part "presence_json.g.dart";

class PresenceViewer extends StatefulWidget {
  final Ditto ditto;
  const PresenceViewer({super.key, required this.ditto});

  @override
  State<PresenceViewer> createState() => _PresenceViewerState();
}

class _PresenceViewerState extends State<PresenceViewer> {
  final _controller = WebViewController();
  PresenceObserver? _observer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _controller.loadFlutterAsset(
      "packages/ditto_flutter_tools/lib/src/presence_assets/index.html",
    );
    _observer = widget.ditto.presence.observe(_onPresenceChanged);
  }

  @override
  void dispose() {
    _observer?.stop();
    super.dispose();
  }

  Future<void> _onPresenceChanged(PresenceGraph graph) async {
    const utf8 = Utf8Encoder();
    final graphJson = _$PresenceGraphToJson(graph);
    final jsonString = jsonEncode(graphJson);
    final graphJsonBase64 = base64Encode(utf8.convert(jsonString));
    await _controller.runJavaScript(
      "Presence.updateNetwork('$graphJsonBase64')",
    );
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
