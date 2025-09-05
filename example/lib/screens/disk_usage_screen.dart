import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:flutter/material.dart';
import 'package:ditto_live/ditto_live.dart';

class DiskUsageScreen extends StatelessWidget {
  final Ditto ditto;

  const DiskUsageScreen({
    super.key,
    required this.ditto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Disk Usage")),
      body: DiskUsageView(ditto: ditto),
    );
  }
}