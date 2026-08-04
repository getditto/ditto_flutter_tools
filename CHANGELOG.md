## 3.0.0

- Requires `ditto_live` 5.0.1 or a later 5.x release. Ditto Flutter SDK 4 is no longer supported.
- Removed `SyncStatusHelper`, `SyncStatusView`, and `SyncStatus`. Use `PeerSyncStatusView` to inspect Ditto's per-peer synchronization records.
- Removed the obsolete `DITTO_WEBSOCKET_URL` example configuration. Ditto 5 derives the server WebSocket endpoint from the authentication URL.
- Fixed `PeerSyncStatusView` loading per-peer sync information with Ditto 5 instead of remaining on the loading screen.
- Retains Peers List, Query Editor, System Settings, Peer Sync Status, Permissions Health, and Disk Usage from 2.0.0.

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
