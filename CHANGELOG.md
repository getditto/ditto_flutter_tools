## 3.0.0 (Unreleased)
- **BREAKING CHANGE**: Removed deprecated `SyncStatusHelper` and `SyncStatusView` classes
  - These have been replaced by the more comprehensive `PeerSyncStatusView`
  - Migration: Replace `SyncStatusView` with `PeerSyncStatusView` in your code
  - The new `PeerSyncStatusView` provides better peer-level synchronization tracking

## 2.0.0
- Updated to Ditto SDK 4.12.1
- Added new features:
  - Query Editor
  - System Settings
  - Peer Sync Status
  - Disk Usage

See README.md for implementation details.

## 1.0.0

Updates to use the GA release of the Ditto SDK

## 0.0.2

Updates to use the latest Ditto SDK release candidate version (4.9.0-rc.3)

## 0.0.1

Initial release containing the `SyncStatusHelper` and `SyncStatusView` tools
