/// Shared types for WiFi permissions health checking
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