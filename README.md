# `ditto_flutter_tools`

Diagnostic and Debugging Tools for Ditto in Flutter

> **⚠️ Platform Compatibility Notice**  
> These tools currently do not support the **Flutter Web platform**. They are designed for mobile (iOS, Android) and desktop (macOS, Linux) platforms where Ditto's peer-to-peer functionality and file system access are available.

> **📋 SDK Requirements**  
> These tools require **Ditto SDK version 4.12.1 or higher**. Ensure your project uses a compatible Ditto version before integrating these diagnostic tools.
> You can find the latest Ditto SDK information in the [Ditto Docs](https://docs.ditto.live/sdk/latest/install-guides/flutter).

## `PeerListView`

The `PeerListView` provides a real-time interface for monitoring connected peers in your Ditto mesh network. This tool helps developers debug peer-to-peer connectivity and understand the network topology by displaying both local and remote peers along with their connection details.

### Usage

The `PeerListView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('Connected Peers')),
  body: PeerListView(ditto: myDittoInstance),
)
```

### Features

The peer list view provides:

1. **Local Peer Information** - Displays information about the current device including its peer key and cloud connectivity status
2. **Remote Peers List** - Shows all currently connected remote peers in the mesh network
3. **Connection Details** - Expandable tiles showing connection types and peer relationships
4. **Real-time Updates** - Automatically updates as peers join and leave the network
5. **Cloud Status Indicators** - Visual icons indicating which peers are connected to Ditto Cloud

### Peer Information Displayed

For each peer (local and remote), the view shows:
- **Device Name** - The human-readable name of the device
- **Peer Key** - The unique identifier for the peer in the mesh network
- **Cloud Connectivity** - Icon indicating if the peer is connected to Ditto Cloud (cloud icon) or offline (cloud_off icon)
- **Active Connections** - Expandable list showing connection details between peers, including connection types

### Real-time Monitoring

The `PeerListView` uses Ditto's presence observer to provide real-time updates:
- Peers are automatically added when they join the network
- Peers are removed when they disconnect
- Connection status changes are reflected immediately
- No manual refresh required


## `PeerSyncStatusView`

The `PeerSyncStatusView` provides a real-time interface for monitoring the synchronization status between your device and connected peers in the Ditto mesh network. This tool queries Ditto's internal `system:data_sync_info` collection to display detailed sync session information, helping developers debug data synchronization issues and monitor sync health.

### Usage

The `PeerSyncStatusView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('Peer Sync Status')),
  body: PeerSyncStatusView(ditto: myDittoInstance),
)
```

### Features

The peer sync status view provides:

1. **Connection Status Grouping** - Separates peers into "Connected" and "Not Connected" sections for quick status overview
2. **Peer Type Identification** - Distinguishes between Cloud Server and Peer Device connections
3. **Sync Session Information** - Shows the synchronization session status for each peer
4. **Database Commit Tracking** - Displays which local database commit ID each peer has synced to
5. **Last Update Timestamps** - Shows when the last sync update was received from each peer
6. **Real-time Updates** - Automatically updates as sync status changes

### Information Displayed

For each peer, the view shows:
- **Peer Type** - Either "Cloud Server" for Ditto Big Peer or "Peer Device" for mesh network peers
- **Peer ID** - The unique identifier for the peer
- **Connection Status** - Visual indicator showing if the peer is currently connected
- **Sync Commit ID** - The local database commit ID that this peer has synced up to (when available)
- **Last Update Time** - Formatted timestamp showing when the last update was received (displays as "Today", "Yesterday", or full date/time)

### Data Source & DQL Strict Mode Support

The `PeerSyncStatusView` automatically detects your Ditto instance's DQL strict mode setting and uses the appropriate query:

This provides access to Ditto's internal synchronization metadata, giving insights into:
- Which peers have active sync sessions (`Connected` vs `Not Connected`)
- How up-to-date each peer is with local data changes (commit IDs)
- When synchronization last occurred with each peer (timestamps)

### Use Cases

This view is particularly useful for:
- **Debugging sync issues** - Identify which peers are not receiving updates
- **Monitoring sync latency** - Check when peers last synchronized  
- **Verifying cloud connectivity** - Confirm that devices are syncing with Ditto Cloud
- **Understanding sync topology** - See which peers are actively participating in data synchronization
- **Performance monitoring** - Track sync commit progress across the network

### Implementation Notes

- **Automatic Mode Detection**: No configuration needed - works with both DQL strict modes
- **Real-time Updates**: Uses Ditto store observers for live sync status monitoring  
- **Proper Lifecycle Management**: Handles widget disposal cleanly to prevent memory leaks
- **Error Handling**: Gracefully handles cases where sync data is unavailable

## `DiskUsageView`

The `DiskUsageView` provides a comprehensive interface for monitoring Ditto database disk usage and exporting data for debugging or backup purposes. This tool helps developers understand storage consumption and provides convenient export functionality for both database files and logs.

### Usage

The `DiskUsageView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('Disk Usage')),
  body: DiskUsageView(ditto: myDittoInstance),
)
```

### Features

The disk usage view provides:

1. **Storage Metrics** - Displays the size of each file and directory within the Ditto persistence directory
2. **Export Database** - Exports the entire Ditto database directory using the Share Dialog 
3. **Export Logs** - Exports Ditto debug logs to a file for troubleshooting

### Export Functionality

Both export features now use the **native platform Share API** for a seamless user experience across all supported platforms.

#### Export Database
- **ZIP Archive Creation**: Creates a compressed ZIP file containing the entire Ditto database directory
- **Includes All Files**: Now includes lock files (`__ditto_lock*`, `lock.mdb`) and system files that were previously excluded - addressing Android lock file issues
- **Background Processing**: ZIP creation runs in a background isolate to prevent UI blocking during large database exports
- **Native Sharing**: Uses the platform's native share dialog to let users choose where to save or send the database export
- **Automatic Cleanup**: Temporary files are automatically cleaned up after sharing (success or cancellation)

#### Export Logs
- **Temporary File Creation**: Creates a timestamped log file (`ditto_log_[timestamp].txt`) to avoid conflicts on repeated exports
- **Native Sharing**: Uses the platform's native share dialog for seamless export experience  
- **Automatic Cleanup**: Temporary log files are cleaned up immediately after sharing

### Share API Benefits
- **Cross-Platform Consistency**: Same sharing experience on iOS, Android, macOS, and Linux
- **Native Integration**: Users can share to any app (email, cloud storage, messaging, etc.)
- **No Permission Management**: No need to handle file system permissions manually
- **Robust Error Handling**: All errors are displayed to users via snackbar notifications

### Permissions & Configuration

> [!NOTE]
> **Share API Advantage**: Since the export functionality now uses the native Share API, **no special file system permissions are required**. The Share API handles all permission management automatically.

#### Current Requirements
- **No additional permissions needed** for export functionality
- The `share_plus` package handles all platform-specific sharing requirements automatically
- Users can share to any compatible app (email, cloud storage, messaging, etc.) through the native platform dialogs

## `SystemSettingsView`

The `SystemSettingsView` provides a comprehensive interface for viewing and inspecting all Ditto system configuration settings. This diagnostic tool helps developers understand the current runtime configuration of their Ditto instance by displaying all system parameters retrieved using the `SHOW ALL` DQL statement.

### Usage

The `SystemSettingsView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('System Settings')),
  body: SystemSettingsView(ditto: myDittoInstance),
)
```

### Features

The system settings view provides:

1. **Dynamic Settings Display** - Automatically displays all available system settings without hardcoded keys, adapting to different Ditto SDK versions
2. **Search Functionality** - Real-time search/filter to quickly find specific settings by key or value
3. **Smart Value Formatting** - Intelligent display of different data types (boolean, number, string, array, object)
4. **Detailed View** - Expandable detail dialog for complex values (arrays, objects, long strings)
5. **Copy to Clipboard** - Easy copying of setting key-value pairs for debugging or documentation
6. **Live Refresh** - Manual refresh button to reload settings and see configuration changes

### Settings Information Displayed

The view displays all system configuration parameters including but not limited to:
- **Replication Settings** - Parameters controlling data synchronization behavior
- **Network Settings** - Configuration for mesh networking, routing, and transports
- **Storage Settings** - Database and blob store configuration
- **Performance Settings** - Timeout values, batch sizes, and optimization parameters
- **Feature Flags** - Enabled/disabled features and experimental options

### Value Visualization

Different data types are displayed with appropriate formatting:
- **Booleans** - Color-coded badges (green for true, grey for false)
- **Numbers** - Monospace font for easy reading
- **Strings** - Truncated with full view on tap for long values
- **Arrays/Objects** - Compact badge showing type and item count, expandable for full JSON view
- **Empty Values** - Clear indication of empty arrays, objects, or strings

### Real-time Search

The search feature allows filtering by:
- Setting key names (e.g., searching for "replication" shows all replication-related settings)
- Setting values (e.g., searching for "true" shows all boolean settings that are enabled)
- Case-insensitive matching for convenience

### Platform Support
- ✅ **iOS**: Full support
- ✅ **Android**: Full support
- ✅ **macOS**: Full support
- ✅ **Linux**: Full support
- ✅ **Web**: Full support (when Ditto Web SDK supports DQL execution)

### Documentation Reference

For more information about system settings and the `SHOW ALL` DQL statement, see the [Ditto documentation on retrieving system values](https://docs.ditto.live/sdk/latest/sync/using-alter-system#retrieving-values).

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

## `QueryEditorView`

The `QueryEditorView` provides an interactive interface for executing DQL (Ditto Query Language) statements against your Ditto database. This tool helps developers test queries, inspect data, and perform CRUD operations during development and debugging, with built-in export functionality for query results.

### Usage

The `QueryEditorView` can be used as a standalone widget in your Flutter application:

```dart
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

// In your widget build method
Scaffold(
  appBar: AppBar(title: Text('Query Editor')),
  body: QueryEditorView(ditto: myDittoInstance),
)
```

Or navigate to it from your debug menu:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QueryEditorView(ditto: ditto),
  ),
);
```

### Features

The query editor provides:

1. **Multi-line Query Input** - A text field for entering DQL statements with syntax hints
2. **Async Query Execution** - Non-blocking query execution with loading indicator  
3. **Paginated Results Display** - Large result sets with configurable pagination (10, 25, 50, 100 items per page)
4. **Export Functionality** - Share query results as JSON files using the native Share API
5. **Error Handling** - Clear error messages for invalid queries or execution failures
6. **Multiple Query Types** - Supports SELECT, INSERT, UPDATE, and DELETE operations

### Export Functionality

The query editor includes built-in export capabilities:

#### Share Results
- **Smart Export**: Share button only appears when query results contain actual data (not status messages)
- **JSON Format**: Results are exported as raw JSON data without formatting or metadata
- **Automatic Cleanup**: Temporary files are automatically cleaned up after sharing

#### Export Features
- **JSON Files**: Query results are exported with `.json` extension and proper MIME type
- **Raw Data Only**: Exports only the actual query result data, no headers or formatting

### Query Results & Pagination

The view handles multiple result types with advanced pagination:

1. **Query Results (SELECT)**: 
   - Each document displayed as a separate item
   - Configurable pagination (10, 25, 50, 100 items per page)
   - Page navigation controls with direct page input
   - Results counter showing total items and current page range
   - Export functionality available for data results

2. **Mutation Results (INSERT/UPDATE/DELETE)**: 
   - List of affected document IDs
   - Number of documents modified  
   - Transaction/commit ID when available
   - No export functionality (status messages only)

### DQL Documentation

For comprehensive DQL syntax and examples, refer to the official Ditto documentation:
- [Read Operations](https://docs.ditto.live/sdk/latest/crud/read)
- [Create Operations](https://docs.ditto.live/sdk/latest/crud/create)  
- [Update Operations](https://docs.ditto.live/sdk/latest/crud/update)
- [Delete Operations](https://docs.ditto.live/sdk/latest/crud/delete)


## `PermissionsHealthView`

The `PermissionsHealthView` provides a real-time monitoring interface for network status, helping developers debug connectivity and peer-to-peer communication issues. This feature mimics the iOS and Android versions of the Ditto Tools.

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
- ❌ **Web**: Not supported - displays a message indicating web platform limitations

### Current Implementation Status

**✅ Fully Working:**
- Bluetooth permission checking (all platforms)
- Simulator/emulator detection (iOS/Android)
- Settings navigation (platform-specific)

### Dependencies

The `PermissionsHealthView` uses the `permission_handler` package to check and request permissions. Make sure your app includes the necessary platform-specific configurations based on the Ditto documentation at:[https://docs.ditto.live/sdk/latest/install-guides/flutter#step-1%3A-add-the-ditto-dependency](https://docs.ditto.live/sdk/latest/install-guides/flutter#step-1%3A-add-the-ditto-dependency)


> [!WARNING]  
>This feature uses the permissions_handler package to check and request permissions.  For the UI to fully function, you must follow the instructions in the [permissions_handler README](https://pub.dev/packages/permission_handler).  Scroll to the Setup section and follow the instructions for iOS which requires to modify the Podfile in your ios directory.  You will have to modify the post_install block to add in a flag to enable the Bluetooth permission so it can detect the Bluetooth status.  Failure to do so will result in the Bluetooth status not being detected.
>

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

## Third-Party Dependencies

This package uses the following third-party libraries:

### Archive Package
- **Package**: `archive` (^3.6.1)
- **Purpose**: Provides ZIP compression functionality for creating database export archives, especially useful on Android where lock files can cause issues with direct file operations.
- **License**: BSD-3-Clause
- **Repository**: https://pub.dev/packages/archive
- **Note**: Used specifically in disk usage export functionality to create ZIP archives containing all database files (including lock files) for sharing via the Share API.

### Share Plus Package  
- **Package**: `share_plus` (^10.1.1)
- **Purpose**: Provides native platform sharing functionality through system share dialogs, replacing manual file picker implementations.
- **License**: BSD-3-Clause
- **Repository**: https://pub.dev/packages/share_plus
- **Note**: Used for all export functionality (logs and database) to provide a consistent, native sharing experience across iOS, Android, macOS, and Linux platforms.



## Support

For support, please contact Ditto Support (<support@ditto.live>).