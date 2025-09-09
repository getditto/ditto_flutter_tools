import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:flutter/material.dart';
import 'package:ditto_live/ditto_live.dart';

class QueryEditorScreen extends StatelessWidget {
  final Ditto ditto;

  const QueryEditorScreen({
    super.key,
    required this.ditto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Query Editor")),
      body: QueryEditorView(
        ditto: ditto,
      ),
    );
  }
}