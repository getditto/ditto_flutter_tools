enum WifiPermissionStatus {
  enabled,
  notConfigured,
  notSupported,
}

class WifiPermissionResult {
  final WifiPermissionStatus status;
  final String message;

  const WifiPermissionResult({
    required this.status,
    required this.message,
  });
}

class WifiAwarePermissionResult {
  final WifiPermissionStatus status;
  final String message;

  const WifiAwarePermissionResult({
    required this.status,
    required this.message,
  });
}

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