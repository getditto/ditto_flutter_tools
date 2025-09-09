# Ditto Flutter Tools Example App

A comprehensive example application demonstrating the usage of the `ditto_flutter_tools` package for debugging and monitoring Ditto peer-to-peer database applications.

## Overview

This example app showcases all the diagnostic tools available in the `ditto_flutter_tools` package, providing developers with a ready-to-use reference implementation for integrating Ditto debugging capabilities into their Flutter applications.

## Features

### 🌐 Network Diagnostics
- **Peers List**: View all connected peers in your Ditto mesh network
  - See peer connection types (Bluetooth, WiFi, WebSocket)
  - Monitor peer presence and connection status
  - Visualize network topology

- **Sync Status**: Real-time monitoring of data synchronization
  - Track sync state for multiple subscriptions
  - View connection status (disconnected, idle, syncing)
  - Monitor last update timestamps

### 💾 System Monitoring
- **Disk Usage**: Monitor Ditto database storage
  - View total disk space consumption
  - Track database growth over time
  - Identify storage optimization opportunities

- **Permissions Health**: Check app permissions status
  - Monitor Bluetooth, WiFi, and location permissions
  - View permission states and requirements
  - Get guidance on enabling required permissions

- **System Settings**: Access device-specific settings
  - Open relevant system settings pages
  - Quick access to Bluetooth and WiFi settings
  - Platform-specific configuration options

### 🔄 Peer Sync Status
- **Peer Sync Status**: Monitor synchronization between specific peers
  - View sync status for individual peer connections
  - Track data flow between devices
  - Identify sync bottlenecks and issues

## Quick Start

### Prerequisites

- Flutter SDK (>=3.4.0)
- Dart SDK (>=3.4.0 <4.0.0)
- A Ditto account with Online Playground credentials

### Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/getditto/ditto_flutter_tools.git
   cd ditto_flutter_tools/example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Ditto credentials**:
   
   Create an environment file from the provided sample:
   ```bash
   cp .env.sample .env
   ```
   
   Open the `.env` file and add your Ditto credentials:
   ```bash
   DITTO_APP_ID="your-app-id-here"
   DITTO_PLAYGROUND_TOKEN="your-playground-token-here"
   DITTO_AUTH_URL="https://your-app.cloud.dittolive.app"
   DITTO_WEBSOCKET_URL="wss://your-app.cloud.dittolive.app"
   ```

   You can obtain these credentials from the [Ditto Portal](https://portal.ditto.live):
   - Log in to your Ditto account
   - Create or select an app
   - Navigate to the "Settings" tab to find your App ID
   - Get your Playground token from the "Authentication" section
   - The Auth URL and WebSocket URL will be displayed in your app settings
   
   **Important**: Never commit the `.env` file to version control. It's already included in `.gitignore` to prevent accidental commits.

4. **Run the app**:
   ```bash
   flutter run
   ```

## Platform Setup

### iOS
Ensure your `ios/Runner/Info.plist` includes:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to sync data with nearby devices</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app uses WiFi to sync data with nearby devices</string>
```

### Android
The following permissions are required in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />
```

### macOS
Enable the following entitlements in `macos/Runner/DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.device.bluetooth</key>
<true/>
```

## Usage Guide

### Viewing Connected Peers
1. Launch the app
2. Tap on "Peers List"
3. View all connected peers and their connection types
4. The list updates in real-time as peers connect/disconnect

### Monitoring Sync Status
1. Launch the app
2. Tap on "Sync Status"
3. View the sync state for each registered subscription
4. Monitor when data was last synchronized

### Checking Disk Usage
1. Launch the app
2. Tap on "Disk Usage"
3. View current database size and storage metrics

### Monitoring Permissions Health
1. Launch the app
2. Tap on "Permissions Health"
3. View the status of all required permissions
4. Follow guidance to enable missing permissions

### Accessing System Settings
1. Launch the app
2. Tap on "System Settings"
3. Access device-specific settings for Bluetooth and WiFi
4. Configure network and connectivity options

### Viewing Peer Sync Status
1. Launch the app
2. Tap on "Peer Sync Status"
3. Monitor synchronization between specific peers
4. Track data flow and identify sync issues

## Project Structure

```
example/
├── lib/
│   ├── main.dart                 # App entry point and routing configuration
│   ├── constants/
│   │   └── routes.dart           # Centralized route definitions
│   ├── services/
│   │   ├── ditto_service.dart    # Ditto SDK initialization and management
│   │   └── subscription_service.dart # Manages sync subscriptions
│   ├── screens/                  # Individual screen implementations
│   │   ├── peers_list_screen.dart
│   │   ├── sync_status_screen.dart
│   │   ├── peer_sync_status_screen.dart
│   │   ├── permissions_health_screen.dart
│   │   ├── disk_usage_screen.dart
│   │   └── system_settings_screen.dart
│   └── widgets/
│       └── main_list_view.dart   # Main navigation interface
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── macos/                        # macOS platform files
├── web/                          # Web platform files
└── pubspec.yaml                  # Dependencies
```

## Routing Architecture

This app uses [Beamer](https://pub.dev/packages/beamer) for navigation, providing a clean and maintainable routing system. All routes are centrally defined to avoid magic strings and ensure consistency.

### Route Management

Routes are defined in `lib/constants/routes.dart` using top-level constants:

```dart
// Route constants - centralized location for all app routes
const String homeRoute = '/';
const String peersRoute = '/peers';
const String syncStatusRoute = '/sync-status';
const String peerSyncStatusRoute = '/peer-sync-status';
const String permissionsHealthRoute = '/permissions-health';
const String diskUsageRoute = '/disk-usage';
const String systemSettingsRoute = '/system-settings';
```

### Navigation Setup

The routing is configured in `main.dart` using Beamer's `RoutesLocationBuilder`:

```dart
final beamerDelegate = BeamerDelegate(
  initialPath: homeRoute,
  locationBuilder: RoutesLocationBuilder(
    routes: {
      homeRoute: (context, state, data) => MainListView(
        dittoService: dittoService,
        subscriptionService: subscriptionService,
      ),
      peersRoute: (context, state, data) => PeersListScreen(
        ditto: dittoService.ditto,
      ),
      // ... other routes
    },
  ),
);
```

### Navigation Usage

Navigate between screens using Beamer:

```dart
// Navigate to a specific route
Beamer.of(context).beamToNamed(peersRoute);

// Navigate back
Beamer.of(context).beamBack();
```

## Customization

### Adding a New Page

To add a new page to the app, follow these steps:

#### 1. Create the Route Constant

Add your new route to `lib/constants/routes.dart`:

```dart
const String myNewPageRoute = '/my-new-page';
```

#### 2. Create the Screen Widget

Create a new file `lib/screens/my_new_page_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

class MyNewPageScreen extends StatelessWidget {
  final Ditto ditto;

  const MyNewPageScreen({
    super.key,
    required this.ditto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My New Page'),
      ),
      body: const Center(
        child: Text('This is my new page!'),
      ),
    );
  }
}
```

#### 3. Add the Route to main.dart

Import your new screen and add it to the routes map in `main.dart`:

```dart
import 'screens/my_new_page_screen.dart';
import 'constants/routes.dart';

// In the BeamerDelegate configuration:
final beamerDelegate = BeamerDelegate(
  initialPath: homeRoute,
  locationBuilder: RoutesLocationBuilder(
    routes: {
      // ... existing routes
      myNewPageRoute: (context, state, data) => MyNewPageScreen(
        ditto: dittoService.ditto,
      ),
    },
  ),
);
```

#### 4. Add Navigation Button

Add a navigation button to `lib/widgets/main_list_view.dart`:

```dart
// Import the routes
import '../constants/routes.dart';

// Add a new ListTile in the appropriate section:
ListTile(
  leading: Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.new_page_icon,
      color: Colors.white,
      size: 20,
    ),
  ),
  title: const Text("My New Page"),
  trailing: Icon(Icons.chevron_right,
      color: Theme.of(context).colorScheme.onSurfaceVariant),
  onTap: () => Beamer.of(context).beamToNamed(myNewPageRoute),
),
```

#### 5. Complete Example

Here's a complete example of adding a "Data Explorer" page:

**Step 1 - Add route constant:**
```dart
// In lib/constants/routes.dart
const String dataExplorerRoute = '/data-explorer';
```

**Step 2 - Create screen:**
```dart
// lib/screens/data_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';

class DataExplorerScreen extends StatelessWidget {
  final Ditto ditto;

  const DataExplorerScreen({
    super.key,
    required this.ditto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Explorer'),
      ),
      body: FutureBuilder(
        future: ditto.store.execute('SELECT * FROM collections'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Collection ${index + 1}'),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

**Step 3 - Add to main.dart:**
```dart
// Add import
import 'screens/data_explorer_screen.dart';

// Add to routes map
dataExplorerRoute: (context, state, data) => DataExplorerScreen(
  ditto: dittoService.ditto,
),
```

**Step 4 - Add navigation button:**
```dart
// In lib/widgets/main_list_view.dart, add to the SYSTEM section:
ListTile(
  leading: Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: Colors.teal,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.explore,
      color: Colors.white,
      size: 20,
    ),
  ),
  title: const Text("Data Explorer"),
  trailing: Icon(Icons.chevron_right,
      color: Theme.of(context).colorScheme.onSurfaceVariant),
  onTap: () => Beamer.of(context).beamToNamed(dataExplorerRoute),
),
```

### Adding Custom Subscriptions

Edit `lib/services/subscription_service.dart` to add your own subscriptions:

```dart
List<SyncSubscription> getSubscriptions() {
  if (_dittoProvider.ditto == null) return [];
  
  // Add your custom subscriptions here
  var customSubscription = _dittoProvider.ditto!.sync.registerSubscription(
    "SELECT * FROM your_collection"
  );
  
  return [customSubscription, /* other subscriptions */];
}
```

### Modifying UI Theme

The app uses Material Design. Customize the theme in `lib/main.dart`:

```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
    // Add your custom theme settings
  ),
  home: DittoExample(),
)
```

## Troubleshooting

### App Won't Initialize
- Verify your `.env` file exists (copy from `.env.sample` if missing)
- Check that all credentials in `.env` are filled in correctly
- Ensure you have an active internet connection
- Verify that your Ditto app is active in the portal

### Permissions Issues
- On iOS: Go to Settings > Privacy and ensure Bluetooth and Local Network are enabled
- On Android: Go to App Settings and grant all requested permissions
- Restart the app after changing permissions

### No Peers Showing
- Ensure Bluetooth and WiFi are enabled on your device
- Run the app on multiple devices to see peer connections
- Check that devices are on the same network (for WiFi sync)

### Sync Not Working
- Verify your WebSocket URL is correct
- Check firewall settings aren't blocking connections
- Ensure your Ditto subscription queries are valid

## Learn More

- [Ditto Flutter Tools Documentation](https://github.com/getditto/ditto_flutter_tools)
- [Ditto Documentation](https://docs.ditto.live)
- [Flutter Documentation](https://flutter.dev/docs)

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/getditto/ditto_flutter_tools/issues)
- Contact Ditto Support at support@ditto.live

## License

This example is part of the ditto_flutter_tools package. See the main repository for license information.