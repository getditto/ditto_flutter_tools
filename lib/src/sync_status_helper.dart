import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/widgets.dart';

enum SyncStatus {
  /// This peer is connected to another peer, and
  connectedIdle,
  connectedSyncing,
  disconnected;

  @override
  String toString() => switch (this) {
        SyncStatus.connectedIdle => "Connected (Idle)",
        SyncStatus.connectedSyncing => "Connected (Syncing)",
        SyncStatus.disconnected => "Disconnected",
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
  var _connected = false;
  DateTime? _lastConnectionEstablished;
  DateTime? _lastConnectionLost;
  DateTime? _lastConnected;
  List<StoreObserver>? _observers;
  PresenceObserver? _presenceObserver;

  SyncStatusHelper({
    required this.ditto,
    required this.subscriptions,
    this.idleTimeoutInterval = const Duration(seconds: 1),
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

    _presenceObserver = await ditto.presence.observe((graph) {
      final isConnectedNow = graph.localPeer.isConnectedToDittoCloud ||
          graph.remotePeers.isNotEmpty;

      if (isConnectedNow) _lastConnected = DateTime.now();
      if (_connected && !isConnectedNow) _lastConnectionLost = DateTime.now();
      if (!_connected && isConnectedNow) {
        _lastConnectionEstablished = DateTime.now();
      }

      _connected = isConnectedNow;
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _presenceObserver?.stop();
    final futures = _observers?.map((observer) => observer.cancel());
    if (futures != null) {
      await Future.wait(futures);
    }
  }

  /// Whether this peer is connected to at least one other peer.
  bool get isConnected => _connected;

  /// The most recent time when this peer was connected to at least one other peer (i.e. [isConnected] is true)
  DateTime? get lastConnectedAt => _lastConnected;

  /// The most recent time when [isConnected] changed from `true` to `false`
  DateTime? get lastConnectionLostAt => _lastConnectionLost;

  /// The most recent time when [isConnected] changed from `false` to `true`
  DateTime? get lastConnectionEstablishedAt => _lastConnectionEstablished;

  /// The overall status of the [SyncSubscription] managed by this helper
  ///
  /// If [isConnected] is `false`, this will be [SyncStatus.disconnected].
  /// Otherwise, if any subscription has had an update in the last [idleTimeoutInterval], it will return [SyncStatus.connectedSyncing].
  /// Otherwise, it will return [SyncStatus.connectedIdle].
  SyncStatus get overallStatus {
    final now = DateTime.now();
    final anyWasRecentlyUpdated =
        subscriptions.any((sub) => _wasRecentlyUpdated(sub, now));

    return switch ((isConnected, anyWasRecentlyUpdated)) {
      (false, _) => SyncStatus.disconnected,
      (true, true) => SyncStatus.connectedSyncing,
      (true, false) => SyncStatus.connectedIdle,
    };
  }

  /// The status for a specific [SyncSubscription]
  ///
  /// If [isConnected] is `false`, this will be [SyncStatus.disconnected].
  /// Otherwise, if the subscription has had updates in the last [idleTimeoutInterval], this will return [SyncStatus.connectedSyncing].
  /// Otherwise, it will return [SyncStatus.connectedIdle].
  SyncStatus statusFor(SyncSubscription subscription) {
    final recentlyUpdated = _wasRecentlyUpdated(subscription, DateTime.now());
    return switch ((isConnected, recentlyUpdated)) {
      (false, _) => SyncStatus.disconnected,
      (true, true) => SyncStatus.connectedSyncing,
      (true, false) => SyncStatus.connectedIdle,
    };
  }

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
