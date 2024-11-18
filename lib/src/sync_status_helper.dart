import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/widgets.dart';

enum SyncStatus {
  idle,
  syncing;

  @override
  String toString() => switch (this) {
        SyncStatus.idle => "Idle",
        SyncStatus.syncing => "Syncing",
      };
}

class SyncStatusHelper with ChangeNotifier {
  final Ditto ditto;

  /// The list of [SyncSubscription] to be checked.
  ///
  /// Note that this list should be considered to be immutable.
  /// Modifying the list after creating the [SyncStatusHelper] may cause incorrect results.
  final List<SyncSubscription> subscriptions;

  // configuration options

  /// The time with no updates required for a particular subscription to be considered idle.
  final Duration idleTimeoutInterval;

  final _lastUpdatedAt = <SyncSubscription, DateTime>{};
  late final List<StoreObserver>? _observers;

  SyncStatusHelper({
    required this.ditto,
    required this.subscriptions,
    this.idleTimeoutInterval = const Duration(seconds: 5),
  }) {
    _init();
  }

  Future<void> _init() async {
    Future<void> onSubscriptionChanged(SyncSubscription sub) async {
      _lastUpdatedAt[sub] = DateTime.now();
      notifyListeners();
      await Future.delayed(idleTimeoutInterval);
      notifyListeners();
    }

    _observers = await _mapObservers(
      ditto,
      subscriptions,
      onSubscriptionChanged,
    );
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    final futures = _observers?.map((observer) => observer.cancel());
    if (futures != null) {
      await Future.wait(futures);
    }
  }

  /// The overall status of the [SyncSubscription] managed by this helper
  ///
  /// If any subscriptions have had updates in the last [idleTimeoutInterval], this will return [SyncStatus.syncing].
  /// Otherwise, it will return [SyncStatus.idle].
  SyncStatus get overallStatus {
    final now = DateTime.now();
    final anyWasRecentlyUpdated =
        subscriptions.any((sub) => _wasRecentlyUpdated(sub, now));

    return switch (anyWasRecentlyUpdated) {
      true => SyncStatus.syncing,
      false => SyncStatus.idle,
    };
  }

  /// The status for a specific [SyncSubscription]
  ///
  /// If the subscription has had updates in the last [idleTimeoutInterval], this will return [SyncStatus.syncing].
  /// Otherwise, it will return [SyncStatus.idle].
  SyncStatus statusFor(SyncSubscription subscription) =>
      switch (_wasRecentlyUpdated(subscription, DateTime.now())) {
        true => SyncStatus.syncing,
        false => SyncStatus.idle,
      };

  DateTime? lastUpdatedAt(SyncSubscription subscription) =>
      _lastUpdatedAt[subscription];

  bool _wasRecentlyUpdated(SyncSubscription subscription, DateTime now) {
    final lastUpdated = _lastUpdatedAt[subscription];
    if (lastUpdated == null) return false;
    return now.difference(lastUpdated) < idleTimeoutInterval;
  }
}

Future<List<StoreObserver>> _mapObservers(
  Ditto ditto,
  List<SyncSubscription> subscriptions,
  void Function(SyncSubscription) onSubscriptionChanged,
) =>
    Future.wait(subscriptions.map(
      (sub) => ditto.store.registerObserver(
        sub.queryString,
        arguments: sub.queryArguments,
        onChange: (_) => onSubscriptionChanged(sub),
      ),
    ));
