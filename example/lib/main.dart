// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:example/presence.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialog.dart';
import 'dql_builder.dart';
import 'task.dart';
import 'task_view.dart';

const appID = "REPLACE_ME_WITH_YOUR_APP_ID";
const token = "REPLACE_ME_WITH_YOUR_PLAYGROUND_TOKEN";

const authAppID = "REPLACE_ME_WITH_YOUR_APP_ID";

const collection = "tasks13";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Ditto.init();

  DittoLogger.isEnabled = false;
  DittoLogger.minimumLogLevel = LogLevel.error;
  DittoLogger.customLogCallback = (level, message) {
    print("[$level] => $message");
  };

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
  Ditto? _ditto;
  var _syncing = true;
  int _pageIndex = 0;

  late final SyncSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _initDitto();
  }

  Future<void> _initDitto() async {
    await [
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
      Permission.bluetoothScan
    ].request();

    final identity = OnlinePlaygroundIdentity(
      appID: appID,
      token: token,
    );

    // final identity = await OnlineWithAuthenticationIdentity.create(
    //   appID: authAppID,
    //   authenticationHandler: AuthenticationHandler(
    //     authenticationExpiringSoon: (authenticator, secondsRemaining) async {
    //       await authenticator.login(token: token, provider: "auth-webhook");
    //     },
    //     authenticationRequired: (authenticator) async {
    //       await authenticator.login(token: token, provider: "auth-webhook");
    //     },
    //   ),
    // );

    final persistenceDirectory = await getApplicationDocumentsDirectory();

    final ditto = await Ditto.open(
      identity: identity,
      persistenceDirectory: "${persistenceDirectory.path}/ditto",
    );

    ditto.updateTransportConfig((config) {
      config.setAllPeerToPeerEnabled(true);
      config.connect.webSocketUrls.add(
        "wss://$authAppID.cloud.ditto.live",
      );
    });
    ditto.deviceName = "Flutter (${ditto.deviceName})";

    ditto.smallPeerInfo.isEnabled = true;
    ditto.smallPeerInfo.syncScope = SmallPeerInfoSyncScope.bigPeerOnly;

    ditto.startSync();

    _subscription = ditto.sync.registerSubscription(
      "SELECT * FROM $collection WHERE deleted = false",
    );

    setState(() => _ditto = ditto);
  }

  Future<void> _addTask() async {
    final pair = await showAddTaskDialog(context, _ditto!);
    if (pair == null) return;
    final (task, attachment) = pair;

    await _ditto!.store.execute(
      "INSERT INTO COLLECTION $collection (${Task.schema}) DOCUMENTS (:task)",
      arguments: {
        "task": {
          ...task.toJson(),
          "image": attachment,
          // "image": { "_id": asasd, "_ditto_internal_...": 2},
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ditto = _ditto;

    if (ditto == null) return _loading;

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
          PresenceView(ditto: _ditto!),
          SyncStatusView(
            ditto: _ditto!,
            subscriptions: [_subscription],
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
            _ditto!.startSync();
          } else {
            _ditto!.stopSync();
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
