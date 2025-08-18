# `ditto_flutter_tools`

Diagnostic and Debugging Tools for Ditto in Flutter

For support, please contact Ditto Support (<support@ditto.live>).

## `PermissionsHealthView`

The `PermissionsHealthView` provides a real-time monitoring interface for Ditto-related permissions, helping developers debug connectivity and peer-to-peer communication issues. This feature mimics the iOS and Android versions of the Ditto Tools.

### Usage

The `PermissionsHealthView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('Permissions Health')),
  body: PermissionsHealthView(),
)
```

### Features

The permissions health view monitors the following:

1. **Bluetooth Permission** - Shows whether your app has been granted Bluetooth access
2. **Bluetooth Status** - Shows if Bluetooth is enabled/disabled on the device
3. **Wi-Fi Status** - Shows peer-to-peer WiFi capabilities (WiFi Direct/AWDL)

The implementation uses platform-specific detection to provide accurate status information:
- **Real Devices**: Attempts to detect actual Bluetooth and WiFi service states
- **Simulators/Emulators**: Shows "Not available on simulator" with appropriate messaging
- **Unsupported Platforms**: Shows "Unknown - Check device settings" with settings access

### Platform Support

- ✅ **iOS**: Monitors Bluetooth permissions and detects simulator environments
- ✅ **Android**: Monitors Bluetooth permissions and detects emulator environments  
- ✅ **macOS**: Monitors Bluetooth permissions and detects simulator environments
- ✅ **Linux/Windows**: Basic permission checking with fallback to settings
- ❌ **Web**: Not supported - displays a message indicating web platform limitations

### Current Implementation Status

**✅ Fully Working:**
- Bluetooth permission checking (all platforms)
- Simulator/emulator detection (iOS/Android)
- Settings navigation (platform-specific)
- Web platform detection and messaging

**⚠️ Partial Implementation:**
- Bluetooth service status (shows "Unknown" - requires native method channels for full accuracy)
- WiFi service status (shows "Unknown" - requires native method channels for full accuracy)

**🚀 Future Enhancement:**
To achieve full parity with iOS and Android native implementations, method channels would need to be added to:
- Check actual Bluetooth adapter state (enabled/disabled/unsupported)
- Check WiFi Direct/AWDL availability and state
- Provide real-time status updates

### Interactive Actions

When permissions are not granted or services are disabled, the view provides action buttons:
- **Grant Permission** - Opens permission request dialog or app settings
- **Enable Bluetooth** - Opens system Bluetooth settings
- **Enable Wi-Fi** - Opens system WiFi settings

### Dependencies

The `PermissionsHealthView` uses the `permission_handler` package to check and request permissions. Make sure your app includes the necessary platform-specific configurations based on the Ditto documentation at:[https://docs.ditto.live/sdk/latest/install-guides/flutter#step-1%3A-add-the-ditto-dependency](https://docs.ditto.live/sdk/latest/install-guides/flutter#step-1%3A-add-the-ditto-dependency)


> [!WARNING]  
>This feature uses the permissions_handler package to check and request permissions.  For the UI to fully function, you must follow the instructions in the [permissions_handler README](https://pub.dev/packages/permission_handler).  Scroll to the Setup section and follow the instructions for iOS which requires to modify the Podfile in your ios directory.  You will have to modify the post_install block to add in a flag to enable the Bluetooth permission so it can detect the Bluetooth status.  Failure to do so will result in the Bluetooth status not being detected.
>

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

## Testing

### Integration Tests

The example app includes comprehensive integration tests for the permissions health feature. These tests verify:

- ✅ **Navigation Lifecycle**: Ensures the permissions health screen survives navigation away and back without crashes
- ✅ **Multiple Navigation Cycles**: Stress tests the navigation to detect memory leaks or stream controller issues  
- ✅ **Real Plugin Data**: Verifies `flutter_blue_plus` and `permission_handler` are working correctly
- ✅ **UI Components**: Checks that all cards, icons, and status text display properly
- ✅ **Pull to Refresh**: Tests the refresh functionality

#### Running Integration Tests

**Requirements:**
- Flutter 3.19+ 
- Connected iOS device/simulator or Android device/emulator

**iOS Testing:**
```bash
# Navigate to example app directory
cd example

# List available iOS simulators
flutter devices

# Run on specific iOS simulator (specify exact device name)
flutter test integration_test -d "iPhone 16 Pro Max"

# Run on physical iOS device (get device ID from flutter devices)
flutter test integration_test -d "Your-iPhone-Device-ID"
```

**Android Testing:**
```bash
# Navigate to example app directory  
cd example

# List available Android devices/emulators
flutter devices

# Run on Android emulator (specify exact device ID)
flutter test integration_test -d emulator-5554

# Run on physical Android device (specify exact device ID)
flutter test integration_test -d "your-android-device-id"
```

**Important Notes:**
- You **must** specify a device with `-d <device-id>` 
- Get exact device IDs from `flutter devices`
- Tests must run on actual devices/simulators (not desktop)
- Ensure Bluetooth permissions are properly configured for your platform

**What the Tests Verify:**

1. **Navigation Lifecycle Bug Fix**: The comprehensive integration test specifically checks that navigating to Permissions Health → Back → Permissions Health → Back → Permissions Health doesn't crash with stream controller errors. This was the critical bug that was fixed.

2. **Real Bluetooth Status**: Verifies the following states are properly detected using `flutter_blue_plus`:
   - `Bluetooth: Enabled` (when Bluetooth is on)
   - `Bluetooth: Disabled` (when Bluetooth is off) 
   - `Bluetooth: Unsupported` (on simulators/unsupported devices)
   - `Bluetooth: Unavailable` (when hardware not available)

3. **Real Permission Status**: Verifies the following states are properly detected using `permission_handler`:
   - `Permission: Allowed Always` (when permission granted)
   - `Permission: Denied` (when permission denied)
   - `Permission: Restricted` (when permission restricted by system)

4. **Lifecycle Management**: Ensures the `BluetoothStatusService` singleton properly manages subscribers and doesn't leak memory or crash on repeated navigation

5. **Multiple Navigation Cycles**: Tests perform multiple round-trip navigation cycles to stress test the lifecycle management and ensure no memory leaks or stream controller issues

**Expected Results:**
- ✅ **All tests pass**: No crashes, proper state detection, navigation works
- ✅ **Console output**: Tests print status information showing detected states
- ✅ **No stream errors**: The original navigation crash bug should be fixed
- ✅ **iOS Tests Working**: Integration tests now run successfully on iOS simulators and devices

**Manual Testing:**
If integration tests can't run in your environment, manually test:
1. Launch example app
2. Tap "Permissions Health" 
3. Verify cards show real Bluetooth/permission states (not hardcoded)
4. Tap back button
5. Tap "Permissions Health" again
6. Verify no crash occurs (this was the original bug)
7. Repeat steps 4-6 multiple times to stress test
