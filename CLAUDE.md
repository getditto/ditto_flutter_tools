# Ditto Flutter Tools

## Project Overview
Flutter package providing diagnostic and debugging tools for Ditto (peer-to-peer database) applications. 

## Tech Stack
- **Framework**: Flutter (>=1.17.0)
- **Language**: Dart (SDK >=3.4.0 <4.0.0)
- **Core Dependency**: ditto_live ^4.9.1
- **Package Type**: Flutter plugin/package

## Project Structure

### Core Library (`/lib`)
- `ditto_flutter_tools.dart` - Main package export file
- **src/**
  - `sync_status_helper.dart` - Monitors subscription sync status programmatically
  - `sync_status_view.dart` - Pre-made UI widget for real-time sync debugging
  - `presence_viewer.dart` - Web-based presence visualization tool
  - `peers_list.dart` - Lists and displays connected peers
  - `log_level_switch.dart` - Controls Ditto logging levels
  - **disk_usage/** - Disk usage monitoring functionality
  - **cross_platform/** - Platform-specific implementations (native/web/stub)
  - **presence_assets/** - Web assets for presence viewer (HTML/JS/CSS)

### Example App (`/example`)
Full Flutter application demonstrating package usage:
- `lib/main.dart` - Main example app
- `lib/presence.dart` - Presence functionality demo
- Platform directories: `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`

## Key Features

### SyncStatusHelper
- Monitors multiple Ditto subscriptions
- Provides sync status: `disconnected`, `connectedIdle`, `connectedSyncing`
- Tracks connection history and last update times
- Configurable idle timeout interval

### SyncStatusView
- Ready-to-use UI component for sync status
- Real-time visualization of sync state
- Embeddable in debug screens

### Presence Viewer
- Web-based visualization of Ditto mesh network
- Shows peer connections and network topology
- Uses embedded HTML/JS/CSS assets

## Development Commands

### Flutter Commands
```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Example App
```bash
# Run example app
cd example
flutter run

# Build for specific platform
flutter build ios
flutter build android
flutter build macos
```

## Important Notes

### Branch Information
- Main branch for PRs: `main`

### Package Assets
The package includes web assets for the presence viewer:
- HTML, JavaScript, and CSS files in `lib/src/presence_assets/`
- These are bundled with the package via `pubspec.yaml` assets declaration

### Platform Support
- iOS, Android, macOS, Linux, Windows, Web
- Cross-platform code in `lib/src/cross_platform/` with platform-specific implementations

### Testing
- Unit tests in `/test` directory
- Example app serves as integration testing platform

## Common Tasks

### Adding New Features
1. Implement in `/lib/src/`
2. Export from `ditto_flutter_tools.dart`
3. Add example usage in `/example/lib/`
4. Write tests in `/test/`

### Updating Dependencies
1. Modify `pubspec.yaml`
2. Run `flutter pub get`
3. Update example app's `pubspec.yaml` if needed
4. Test on all supported platforms

## Support
For support, contact Ditto Support at support@ditto.live
Repository: https://github.com/getditto/ditto_flutter_tools