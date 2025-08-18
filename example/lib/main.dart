// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:example/widgets/presence.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'providers/ditto_provider.dart';
import 'services/tasks_service.dart';

import 'widgets/dialog.dart';
import 'dql_builder.dart';
import 'models/task.dart';
import 'widgets/task_view.dart';

const appID = "a48453d8-c2c3-495b-9f36-80189bf5e135";
const token = "8304ca7f-e843-47ed-a0d8-32cc5ff1be7e";
const authUrl = "https://m1tpgv.cloud.dittolive.app";
const websocketUrl = "wss://m1tpgv.cloud.dittolive.app";

const authAppID = "REPLACE_ME_WITH_YOUR_APP_ID";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DittoExample(),
  ));
}

class DittoExample extends StatefulWidget {
  const DittoExample({super.key});

  @override
  State<DittoExample> createState() => _DittoExampleState();
}

class _DittoExampleState extends State<DittoExample> {
  DittoProvider? _dittoProvider;
  TaskService? _taskService;

  var _syncing = true;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();

    _initDitto();
  }

  Future<void> _initDitto() async {
    final dittoProvider = DittoProvider();
    final taskService = TaskService();

    await dittoProvider.initialize(appID, token, authUrl, websocketUrl);
    await taskService.initialize(dittoProvider);

    setState(() => _dittoProvider = dittoProvider);
    setState(() => _taskService = taskService);
  }

  Future<void> _addTask() async {
    if (_dittoProvider == null || _taskService == null) return;
    final pair = await showAddTaskDialog(context, _dittoProvider!.ditto!);
    if (pair == null) return;
    final (task, attachment) = pair;
    await _taskService!.addTask(task.toJson(), attachment);
  }

  @override
  Widget build(BuildContext context) {
    final dittoProvider = _dittoProvider;
    if (dittoProvider == null) return _loading;

    return Scaffold(
      appBar: AppBar(title: const Text("Ditto Tasks")),
      floatingActionButton: _pageIndex == 0 ? _fab : null,
      body: IndexedStack(
        index: _pageIndex,
        children: [
          Column(
            children: [
              _syncTile,
              // const LogLevelSwitch(),
              const Divider(height: 1),
              Expanded(child: _tasksList),
            ],
          ),
          PresenceView(dittoProvider: _dittoProvider!),
          SyncStatusView(
            ditto: _dittoProvider!.ditto!,
            subscriptions: [_taskService!.taskSubscription!],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: "Presence"),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: "Sync Status"),
        ],
        currentIndex: _pageIndex,
        onTap: (value) => setState(() => _pageIndex = value),
      ),
    );
  }

  Widget get _loading => Scaffold(
        appBar: AppBar(title: const Text("Ditto Tasks")),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget get _fab => FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add_task),
      );

  Widget get _syncTile => SwitchListTile(
        title: const Text("Syncing"),
        value: _syncing,
        onChanged: (value) async {
          if (value) {
            _dittoProvider!.ditto!.startSync();
          } else {
            _dittoProvider!.ditto!.stopSync();
          }

          setState(() => _syncing = value);
        },
      );

  Widget get _tasksList => DqlBuilder(
        ditto: _ditto!,
        query:
            "SELECT * FROM COLLECTION $collection (${Task.schema}) WHERE deleted = false",
        builder: (context, response) {
          Widget makeTaskView(QueryResultItem result) {
            final task = Task.fromJson(result.value);
            final imageToken = result.value["image"];

            return _singleTask(task, imageToken);
          }

          final tasks = response.items.map(makeTaskView);

          return ListView(children: [...tasks]);
        },
      );

  Widget _singleTask(Task task, Map<String, dynamic>? image) => Dismissible(
        key: Key("${task.id}-${task.title}"),
        onDismissed: (direction) async {
          await _ditto!.store.execute(
            "UPDATE $collection SET deleted = true WHERE _id = '${task.id}'",
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Deleted Task ${task.title}")),
            );
          }
        },
        background: _dismissibleBackground(true),
        secondaryBackground: _dismissibleBackground(false),
        child: TaskView(ditto: _ditto!, task: task, token: image),
      );

  Widget _dismissibleBackground(bool primary) => Container(
        color: Colors.red,
        child: Align(
          alignment: primary ? Alignment.centerLeft : Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.delete),
          ),
        ),
      );

  // Widget get _menuButton => MenuAnchor(
  //       builder: (context, controller, child) => IconButton(
  //         icon: const Icon(Icons.menu),
  //         onPressed: () {
  //           if (controller.isOpen) {
  //             controller.close();
  //           } else {
  //             controller.open();
  //           }
  //         },
  //       ),
  //       menuChildren: [
  //         MenuItemButton(
  //           child: const Text("Show Disk Usage"),
  //           onPressed: () => DiskUsage.show(context, ditto),
  //         ),
  //       ],
  //     );
}
