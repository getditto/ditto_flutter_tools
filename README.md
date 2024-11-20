# `ditto_flutter_tools`

Diagnostic and Debugging Tools for Ditto in Flutter

## `SyncStatusHelper` and `SyncStatusView`

These tools are intended to provide insights into the status of your subscriptions.
`SyncStatusHelper` provides programmatic access to the collected data, and `SyncStatusView` provides a pre-made UI that can be embedded in an app for real-time debugging.

To use it, pass in your `Ditto` instance, as well as a list of subscriptions you wish to monitor:
```dart
final syncStatusHelper = SyncStatusHelper(
  ditto: ditto,
  subscriptions: [
    mySubscription1,
    mySubscription2,
  ],
);
```
Alternatively, if you want to use all the subscriptions that are currently active, use the `fromCurrentSubscriptions` constructor:
```dart
final syncStatusHelper = SyncStatusHelper.fromCurrentSubscriptions(
  ditto: ditto,
);
```
Note that this will only monitor the subscriptions that are currently active. If you register a new subscription to the underlying `Ditto` instance, the `SyncStatusHelper` will not update.

### Querying the data

The helper provides an `overallStatus` getter, which provides a high-level overview of all subscriptions. This returns a `SyncStatus`:
 - if your device is not connected to any other peers, `overallStatus` will be `disconnected`
 - if your device is connected to at least one peer, and none of the subscriptions have been updated recently, `overallStatus` will be `connectedIdle`
 - if your device is connected to at least one peer, and at least one of the subscriptions has been updated recently, `overallStatus` will be `connectedSyncing`

You can configure the maximum time that can have passed for an update to be considered "recent" by providing the optional `idleTimeoutInterval` parameter (defaults to one second).

You can also inspect individual subscriptions:
```dart
final helper = SyncStatusHelper(/* ... */);
final subscription = helper.subscriptions[0];

// the `SyncStatus` for a particular subscription
print(helper.statusFor(subscription));

// a `DateTime?`, null if this subscription has never been updated
print(helper.lastUpdatedAt(subscription))
```

You can also see details about the connectivity of the device.
A device is considered "connected" if and only if it is connected to at least one other peer.

```dart
final helper = SyncStatusHelper(/* ... */);

// Is the device currently connected
print(helper.isConnected);

// A `DateTime?` representing the most recent time this device was connected
// Will be `null` if this device has never been connected
print(helper.lastConnectedAt);

// `DateTime?`s representing the last time the connectivity status changed
print(helper.becameConnectedAt);
print(helper.becameDisconnectedAt);
```

For example, if a device had become connected to another device five minutes ago, and the connection had been uninterrupted for the entire duration:
 - `lastConnectedAt` would be very close to `DateTime.now()` (though not exactly due to slight delay in reporting connectivity changes)
 - `becameConnectedAt` would be five minutes ago
 - `becameDisconnectedAt` would be `null`

If, on the other hand, the device lost connectivity for one minute during that five minute period, you might see something like:
 - `lastConnectedAt` would be very close to `DateTime.now()` (though not exactly due to slight delay in reporting connectivity changes)
 - `becameConnectedAt` would be two minutes ago
 - `becameDisconnectedAt` would be three minutes ago


### Interpreting the data

TODO
