import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:ditto_live/ditto_live.dart';
import 'package:example/models/task.dart';

import 'package:example/providers/ditto_provider.dart';

class TaskService with ChangeNotifier {
  DittoProvider? _dittoProvider;

  // Subscriptions
  SyncSubscription? _tasksSubscription;

  /// The Ditto instance used for database operations
  SyncSubscription? get taskSubscription => _tasksSubscription;

  // Observers
  StoreObserver? _tasksObserver;

  // Stream controllers with replay capability - now return actual objects
  final _tasksStreamController = StreamController<List<Task>>.broadcast();

  // Cache the latest results for immediate access
  List<Task>? _latestTasksList;

  /// Stream of task listings with immediate cache
  Stream<List<Task>> get tasksStream async* {
    // Immediately yield cached result if available
    if (_latestTasksList != null) {
      yield _latestTasksList!;
    }
    // Then yield all future updates
    yield* _tasksStreamController.stream;
  }

  Future<void> initialize(DittoProvider dittoProvider) async {
    _dittoProvider = dittoProvider;

    _tasksSubscription = _dittoProvider?.ditto?.sync
        .registerSubscription("SELECT * FROM tasks WHERE deleted = false");

    // Set up observers that will run for the app lifecycle
    _setupObservers();
  }

  Future<void> addTask(
      Map<String, dynamic> task, AttachmentToken attachment) async {
    if (_dittoProvider == null) return;

    await _dittoProvider!.ditto!.store.execute(
      "INSERT INTO COLLECTION tasks (${Task.schema}) DOCUMENTS (:task)",
      arguments: {
        "task": {
          ...task,
          "image": attachment,
          // "image": { "_id": asasd, "_ditto_internal_...": 2},
        },
      },
    );
  }

  /// Set up all observers for the app lifecycle
  void _setupObservers() {
    if (_dittoProvider == null) return;

    try {
      // Movies observer - for the movies screen
      _tasksObserver = _dittoProvider!.ditto!.store.registerObserver(
        "SELECT * FROM tasks",
      );

      _tasksObserver!.changes.listen((result) {
        // Deserialize in background using compute
        compute(_deserializeTaskListings,
                result.items.map((item) => item.value).toList())
            .then((tasks) {
          _latestTasksList = tasks; // Cache the deserialized result
          if (!_tasksStreamController.isClosed) {
            _tasksStreamController.add(tasks);
          }
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up observers: $e');
      }
    }
  }

  @override
  void dispose() {
    // Cancel subscriptions
    _tasksSubscription?.cancel();

    // Cancel observers
    _tasksObserver?.cancel();

    // Close stream controllers
    _tasksStreamController.close();

    super.dispose();
  }
}

// Static functions for background deserialization
List<Task> _deserializeTaskListings(List<Map<String, dynamic>> data) {
  return data.map((item) => Task.fromJson(item)).toList();
}
