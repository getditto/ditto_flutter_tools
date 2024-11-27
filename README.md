# `ditto_flutter_tools`

Diagnostic and Debugging Tools for Ditto in Flutter

For support, please contact Ditto Support (<support@ditto.live>).

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

#### No historical tracking

`SyncStatusHelper` only tracks data from the point at which it was created, and cannot provide data about any point in time before its creation.

So for example, if your device was connected five minutes ago, then lost connectivity one minute ago, then you created a `SyncStatusHelper`, it would report that this device had never been connected.

#### Peer-to-peer specific interpretations

The sync state means:
 - `disconnected` - you are not connected to other peers
 - `connectedIdle` - you are connected to at least one peer and have not received recent updates
 - `connectedSyncing` - you are connected to at least one peer and have received at least one recent update

When connected to a big peer, being in a `connectedIdle` state can be interpreted as meaning "I am up to date with what the big peer has".
However, if connected via peer-to-peer connection to another small peer, that interpretation isn't always correct.

For example:
 - you could be connected to another peer, but you are islanded from the rest of the mesh
 - the peer you are connected to could have a different set of sync subscriptions, and so would have incomplete data

#### Freshness

You may also want to consider the "freshness" of data when you are disconnected.
For example, consider the following scenarios:
 - your device is `disconnected`, your subscription was last updated five days ago, and `lastConnectedAt` is five days ago
 - your device is `disconnected`, your subscription was last updated five days ago, and `lastConnectedAt` is 1 minute ago

In the second scenario, you can be quite confident that your data is still the most up-to-date version; it's quite unlikely that you have had no updates in the last five days, but in the one minute you've been offline, there's new data. Compare that with the first scenario, in which the last update was exactly when you lost connectivity.

That said, the aim of this tool is to provide heuristics that you can combine with an understanding of your data model to get an accurate picture of the state of your device.
If you have specific knowledge about your data model or update frequency, you can use that knowledge to get a clearer view of the data you have locally.
