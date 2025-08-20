# Ditto Flutter Tools Example App

## Project Overview
Example Flutter application demonstrating the usage of the ditto_flutter_tools package for Ditto peer-to-peer database debugging and diagnostics.

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart (SDK >=3.4.0 <4.0.0)
- **Core Dependencies**:
  - `ditto_live`: 4.12.0 (Peer-to-peer database SDK)
  - `ditto_flutter_tools`: Local package (parent directory)
  - `permission_handler`: ^11.3.1 (Platform permissions)
  - `path_provider`: ^2.1.5 (File system paths)

## Project Structure

### Main Application (`/lib`)
- `main.dart` - Main app entry point with Ditto tools showcase
- **providers/**
  - `ditto_provider.dart` - Ditto SDK initialization and configuration
- **services/**
  - `subscription_service.dart` - Manages Ditto sync subscriptions
- **widgets/**
  - `presence.dart` - Presence visualization widget

### Platform Directories
- `android/` - Android platform configuration
- `ios/` - iOS platform configuration
- `macos/` - macOS platform configuration
- `linux/` - Linux platform configuration
- `web/` - Web platform configuration

## Application Setup

### Ditto Configuration
The app uses Online Playground identity for testing. Update these constants in `main.dart`:
```dart
const appID = "YOUR_APP_ID";
const token = "YOUR_TOKEN";
const authUrl = "YOUR_AUTH_URL";
const websocketUrl = "YOUR_WEBSOCKET_URL";
```

### Key Components

#### DittoProvider
- Handles Ditto SDK initialization
- Manages permissions (Bluetooth, WiFi)
- Configures peer-to-peer and WebSocket connections
- Sets up persistent storage

#### SubscriptionService
- Registers sync subscriptions for collections:
  - `tasks` collection
  - `movies` collection
  - `comments` collection

#### Main Features Screen
Provides access to diagnostic tools:
- **Network Tools**:
  - Peers List - View connected peers
  - Sync Status - Monitor subscription sync state
- **System Tools**:
  - Disk Usage - Monitor Ditto database disk usage

## Running the App

### Prerequisites
1. Install Flutter SDK (>=3.4.0)
2. Configure Ditto credentials in `main.dart`
3. Ensure platform-specific setup is complete

### Commands
```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for specific platform
flutter build ios
flutter build android
flutter build macos
flutter build web
```

## Platform Permissions

### iOS
Add to `Info.plist`:
- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`
- `NSLocalNetworkUsageDescription`

### Android
Permissions in `AndroidManifest.xml`:
- `BLUETOOTH`
- `BLUETOOTH_ADMIN`
- `BLUETOOTH_SCAN`
- `BLUETOOTH_ADVERTISE`
- `BLUETOOTH_CONNECT`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_WIFI_STATE`
- `CHANGE_WIFI_STATE`
- `NEARBY_WIFI_DEVICES`

### macOS
Configure entitlements:
- `com.apple.security.network.client`
- `com.apple.security.device.bluetooth`

## Testing Ditto Tools

### Sync Status View
1. Launch the app
2. Navigate to "Sync Status"
3. View real-time sync state for each subscription
4. Monitor connection status and last update times

### Peers List
1. Launch the app
2. Navigate to "Peers List"
3. View connected peers and their connection types
4. See network topology visualization

### Disk Usage
1. Launch the app
2. Navigate to "Disk Usage"
3. View Ditto database storage metrics
4. Monitor disk space consumption

## Common Issues

### Initialization Failures
- Verify Ditto credentials are correct
- Check network connectivity
- Ensure permissions are granted

### Sync Not Working
- Verify WebSocket URL is accessible
- Check firewall settings
- Ensure peer-to-peer is enabled on platform

### Permission Errors
- Grant all required permissions
- Restart app after permission changes
- Check platform-specific permission setup

## Development Notes

### Adding New Subscriptions
Edit `subscription_service.dart`:
```dart
var newSubscription = _dittoProvider.ditto!.sync.registerSubscription("SELECT * FROM new_collection");
```

### Customizing UI
The app uses Material Design with iOS-style navigation transitions. Modify theme in `main.dart`.

### Error Handling
The app includes error states for:
- Ditto initialization failures
- Missing permissions
- Network connectivity issues