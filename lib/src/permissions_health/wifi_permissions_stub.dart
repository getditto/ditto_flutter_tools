Never get _$ => throw "stub";

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
Future<WifiPermissionResult> checkWifiPermissions() => _$;

/// Check if WiFi Aware permissions are properly configured for Ditto (Android only)
Future<WifiAwarePermissionResult> checkWifiAwarePermissions() => _$;