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

## Project Structure

```
example/
├── lib/
│   ├── main.dart                 # App entry point and main UI
│   ├── providers/
│   │   └── ditto_provider.dart   # Ditto SDK initialization
│   ├── services/
│   │   └── subscription_service.dart # Manages sync subscriptions
│   └── widgets/
│       └── presence.dart         # Presence visualization
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── macos/                        # macOS platform files
├── web/                          # Web platform files
└── pubspec.yaml                  # Dependencies
```

## Customization

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