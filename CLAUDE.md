# Ditto Flutter Tools

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Flutter package providing diagnostic and debugging tools for Ditto (peer-to-peer database) applications. 

## Tech Stack
- **Framework**: Flutter (>=1.17.0)
- **Language**: Dart (SDK >=3.4.0 <4.0.0)
- **Core Dependency**: ditto_live ^4.12.1
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

### PeerListView
- Real-time monitoring of connected peers in mesh network
- Displays local and remote peer information
- Shows connection details and cloud connectivity status
- Expandable interface with peer key and device name display

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

### Code Quality Rule
**IMPORTANT**: Always run `flutter analyze` before completing any code changes to ensure no warnings or errors are introduced. All warnings must be fixed before code completion.

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
- iOS, Android, macOS, Linux, Web
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

# General Rules
- Keep conversations concise. Do not give compliments. Do not apologize. Do not try to please the user. Do not be chatty or witty.  Most Ditto developers usually work on a Mac, but are required to occasionally work with Unix and Windows to test this project.
- If you need useful commands or scripts that are not installed on this machine, you can ask me to install them.
- **NEVER CHANGE FLUTTER or Ditto SDK VERSION**: This project MUST use what is currently defined. 
- - After creating a plan, prompt me to save that plan to a `PLAN.md` file. Save all the details you would need to restart the plan in a new session. As you implement the plan, periodically update that `PLAN.md` file to mark completed tasks and note any changes to the plan.  The PLAN.md file should always be saved into the claude directory.
    -I will often ask you to save a summary of the conversation to a `CONVERSATION.md` file. Save all details that you would need to continue the conversation in a new session.  The CONVERSATION.md file should always be saved into the claude directory.
- When starting a session, if you see `PLAN.md` and/or `CONVERSATION.md` in the root directory, or in a subdirectory named `claude`, then ask whether you should read those files.
- If I ask you to "save plan and conversation", that means you should update the existing `PLAN.md` and `CONVERSATION.md` files with current status, or create new `PLAN.md` and `CONVERSATION.md` files in the claude directory.
- the claude directory is used for all claude related files and should not be used for any other purpose.
- the claude\errors directory is used for all error related files and should not be used for any other purpose.
- the claude\designs directory is used for all design related files and should not be used for any other purpose.

# Code Style
- Always recommend dart code vs trying to use native code in Swift or Kotlin, etc.   If required, look for 3rd party libraries that might be available that publish solutions that work in all platforms (mac, linux, windows, android, ios, web).