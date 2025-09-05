import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:flutter/material.dart';

class PermissionsHealthScreen extends StatelessWidget {
  const PermissionsHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permissions Health")),
      body: const PermissionsHealthView(),
    );
  }
}