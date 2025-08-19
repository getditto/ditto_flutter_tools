import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing Bluetooth permissions using permission_handler
class BluetoothPermissionsService {
  static final BluetoothPermissionsService _instance =
      BluetoothPermissionsService._internal();
  factory BluetoothPermissionsService() => _instance;
  BluetoothPermissionsService._internal();

  /// Get the appropriate Bluetooth permission for the current platform
  Permission get _bluetoothPermission {
    if (Platform.isAndroid) {
      return Permission.bluetoothConnect;
    }
    return Permission.bluetooth;
  }

  /// Get current Bluetooth permission status
  Future<PermissionStatus> getBluetoothPermissionStatus() async {
    try {
      return await _bluetoothPermission.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Request Bluetooth permission
  Future<PermissionStatus> requestBluetoothPermission() async {
    try {
      return await _bluetoothPermission.request();
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Check if Bluetooth permission is granted
  Future<bool> isBluetoothPermissionGranted() async {
    final status = await getBluetoothPermissionStatus();
    return status == PermissionStatus.granted;
  }

  /// Get human-readable string for permission status
  Future<String> getPermissionStatusString() async {
    final status = await getBluetoothPermissionStatus();
    switch (status) {
      case PermissionStatus.granted:
        return 'Allowed Always';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  /// Get status indicator for UI (granted, denied, restricted, etc.)
  Future<String> getStatusIndicator() async {
    final status = await getBluetoothPermissionStatus();
    switch (status) {
      case PermissionStatus.granted:
        return 'granted';
      case PermissionStatus.denied:
        return 'denied';
      case PermissionStatus.restricted:
        return 'restricted';
      case PermissionStatus.limited:
        return 'limited';
      case PermissionStatus.permanentlyDenied:
        return 'permanently_denied';
      case PermissionStatus.provisional:
        return 'provisional';
    }
  }

  /// Check if permission can be requested
  Future<bool> canRequestPermission() async {
    final status = await getBluetoothPermissionStatus();
    return status != PermissionStatus.permanentlyDenied &&
        status != PermissionStatus.restricted;
  }
}
