import 'dart:io';
import 'package:flutter/services.dart';

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

const MethodChannel _channel = MethodChannel('ditto_wifi_permissions');

/// Check if WiFi permissions are properly configured for Ditto
Future<WifiPermissionResult> checkWifiPermissions() async {
  try {
    if (Platform.isIOS) {
      return await _checkiOSWifiPermissions();
    } else if (Platform.isAndroid) {
      return await _checkAndroidWifiPermissions();
    } else {
      return const WifiPermissionResult(
        status: WifiPermissionStatus.notSupported,
        message: 'Platform not supported',
      );
    }
  } catch (e) {
    return WifiPermissionResult(
      status: WifiPermissionStatus.notConfigured,
      message: 'Error checking permissions: $e',
    );
  }
}

/// Check if WiFi Aware permissions are properly configured for Ditto (Android only)
Future<WifiAwarePermissionResult> checkWifiAwarePermissions() async {
  try {
    if (Platform.isAndroid) {
      return await _checkAndroidWifiAwarePermissions();
    } else {
      return const WifiAwarePermissionResult(
        status: WifiPermissionStatus.notSupported,
        message: 'Platform not supported',
      );
    }
  } catch (e) {
    return WifiAwarePermissionResult(
      status: WifiPermissionStatus.notConfigured,
      message: 'Error checking permissions: $e',
    );
  }
}

Future<WifiPermissionResult> _checkiOSWifiPermissions() async {
  try {
    final result = await _channel.invokeMethod('checkiOSWifiPermissions');
    final Map<String, dynamic> response = Map<String, dynamic>.from(result);
    
    final bool isConfigured = response['isConfigured'] ?? false;
    final String message = response['message'] ?? 'Unknown status';
    
    return WifiPermissionResult(
      status: isConfigured ? WifiPermissionStatus.enabled : WifiPermissionStatus.notConfigured,
      message: message,
    );
  } catch (e) {
    return WifiPermissionResult(
      status: WifiPermissionStatus.notConfigured,
      message: 'Failed to check iOS WiFi permissions: $e',
    );
  }
}

Future<WifiPermissionResult> _checkAndroidWifiPermissions() async {
  try {
    final result = await _channel.invokeMethod('checkAndroidWifiPermissions');
    final Map<String, dynamic> response = Map<String, dynamic>.from(result);
    
    final bool isConfigured = response['isConfigured'] ?? false;
    final String message = response['message'] ?? 'Unknown status';
    
    return WifiPermissionResult(
      status: isConfigured ? WifiPermissionStatus.enabled : WifiPermissionStatus.notConfigured,
      message: message,
    );
  } catch (e) {
    return WifiPermissionResult(
      status: WifiPermissionStatus.notConfigured,
      message: 'Failed to check Android WiFi permissions: $e',
    );
  }
}

Future<WifiAwarePermissionResult> _checkAndroidWifiAwarePermissions() async {
  try {
    final result = await _channel.invokeMethod('checkAndroidWifiAwarePermissions');
    final Map<String, dynamic> response = Map<String, dynamic>.from(result);
    
    final bool isConfigured = response['isConfigured'] ?? false;
    final String message = response['message'] ?? 'Unknown status';
    
    return WifiAwarePermissionResult(
      status: isConfigured ? WifiPermissionStatus.enabled : WifiPermissionStatus.notConfigured,
      message: message,
    );
  } catch (e) {
    return WifiAwarePermissionResult(
      status: WifiPermissionStatus.notConfigured,
      message: 'Failed to check Android WiFi Aware permissions: $e',
    );
  }
}