import 'wifi_permissions_types.dart';

Never get _unsupportedPlatformStub => throw "Unsupported Platform";

/// Check if WiFi permissions are properly configured for Ditto
Future<WifiPermissionResult> checkWifiPermissions() => _unsupportedPlatformStub;

/// Check if WiFi Aware permissions are properly configured for Ditto (Android only)
Future<WifiAwarePermissionResult> checkWifiAwarePermissions() =>
    _unsupportedPlatformStub;
