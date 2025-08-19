import 'wifi_permissions_types.dart';

/// Check if WiFi permissions are properly configured for Ditto
Future<WifiPermissionResult> checkWifiPermissions() async {
  return const WifiPermissionResult(
    status: WifiPermissionStatus.notSupported,
    message: 'Platform not supported',
  );
}

/// Check if WiFi Aware permissions are properly configured for Ditto (Android only)
Future<WifiAwarePermissionResult> checkWifiAwarePermissions() async {
  return const WifiAwarePermissionResult(
    status: WifiPermissionStatus.notSupported,
    message: 'Platform not supported',
  );
}