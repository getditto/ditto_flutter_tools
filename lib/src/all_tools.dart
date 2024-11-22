import 'package:ditto_flutter_tools/src/log/logging_tools.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

class AllTools extends StatefulWidget {
  final Ditto ditto;
  const AllTools({super.key, required this.ditto});

  @override
  State<AllTools> createState() => _AllToolsState();
}

class _AllToolsState extends State<AllTools> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Ditto Tools"),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (page) => setState(() => _currentPage = page),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Logging",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sync),
              label: "Sync",
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentPage,
          children: const [
            LoggingTools(),
            Placeholder(),
          ],
        ),
      );
}
