import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Service for managing Bluetooth status using flutter_blue_plus
class BluetoothStatusService {
  static final BluetoothStatusService _instance = BluetoothStatusService._internal();
  factory BluetoothStatusService() => _instance;
  BluetoothStatusService._internal();

  /// Stream controller for Bluetooth adapter state changes
  StreamController<BluetoothAdapterState>? _stateController;

  /// Stream of Bluetooth adapter state changes
  Stream<BluetoothAdapterState> get adapterStateStream {
    _ensureInitialized();
    return _stateController!.stream;
  }

  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  int _subscriberCount = 0;
  bool _isInitialized = false;

  /// Initialize the Bluetooth service and start listening to adapter state changes
  Future<void> initialize() async {
    _subscriberCount++;
    if (_isInitialized) {
      return; // Already initialized
    }
    
    _ensureInitialized();
    
    // Start listening to adapter state changes
    try {
      _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (_stateController != null && !_stateController!.isClosed) {
          _stateController!.add(state);
        }
      });
    } catch (e) {
      // Platform not supported (e.g., in tests or unsupported platforms)
      // Service will still work but won't provide real-time updates
    }
    
    _isInitialized = true;
  }
  
  /// Ensure the stream controller is created and ready
  void _ensureInitialized() {
    if (_stateController == null || _stateController!.isClosed) {
      _stateController = StreamController<BluetoothAdapterState>.broadcast();
    }
  }

  /// Get current Bluetooth adapter state
  BluetoothAdapterState get currentAdapterState {
    return FlutterBluePlus.adapterStateNow;
  }

  /// Check if Bluetooth is supported on this device
  Future<bool> isBluetoothSupported() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get fresh Bluetooth adapter state (for Android emulator issues)
  Future<BluetoothAdapterState> getFreshAdapterState() async {
    try {
      // First check if Bluetooth is supported
      final isSupported = await isBluetoothSupported();
      
      if (!isSupported) {
        return BluetoothAdapterState.unavailable;
      }
      
      // Return current state
      return currentAdapterState;
    } catch (e) {
      // If there's an error, assume unavailable (common on emulators)
      return BluetoothAdapterState.unavailable;
    }
  }

  /// Check if Bluetooth is currently enabled
  bool get isBluetoothEnabled {
    return currentAdapterState == BluetoothAdapterState.on;
  }

  /// Get human-readable string for current Bluetooth state
  String get bluetoothStateString {
    switch (currentAdapterState) {
      case BluetoothAdapterState.unknown:
        return 'Unknown';
      case BluetoothAdapterState.unavailable:
        return 'Unavailable';
      case BluetoothAdapterState.unauthorized:
        return 'Unauthorized';
      case BluetoothAdapterState.turningOn:
        return 'Turning On';
      case BluetoothAdapterState.on:
        return 'Enabled';
      case BluetoothAdapterState.turningOff:
        return 'Turning Off';
      case BluetoothAdapterState.off:
        return 'Disabled';
    }
  }

  /// Get status indicator for UI (enabled, disabled, unsupported, unknown)
  String get statusIndicator {
    switch (currentAdapterState) {
      case BluetoothAdapterState.on:
        return 'enabled';
      case BluetoothAdapterState.off:
        return 'disabled';
      case BluetoothAdapterState.unavailable:
        return 'unsupported';
      case BluetoothAdapterState.unauthorized:
        return 'unauthorized';
      case BluetoothAdapterState.turningOn:
      case BluetoothAdapterState.turningOff:
        return 'transitioning';
      case BluetoothAdapterState.unknown:
      default:
        return 'unknown';
    }
  }

  /// Check if Bluetooth can be enabled (i.e., not unsupported)
  bool get canEnableBluetooth {
    return currentAdapterState != BluetoothAdapterState.unavailable;
  }

  /// Get detailed Bluetooth support information
  Future<Map<String, dynamic>> getDetailedBluetoothInfo() async {
    final info = <String, dynamic>{};
    
    try {
      // Check if Bluetooth is supported
      final isSupported = await FlutterBluePlus.isSupported;
      info['isSupported'] = isSupported;
      info['supportedString'] = isSupported ? 'Supported' : 'Not Supported';
      
      // Get current adapter state
      final adapterState = currentAdapterState;
      info['adapterState'] = adapterState;
      info['adapterStateString'] = bluetoothStateString;
      
      // PHY support information (Android-specific)
      if (Platform.isAndroid) {
        try {
          final phySupport = await FlutterBluePlus.getPhySupport();
          info['phySupport'] = phySupport;
          info['phySupportDetails'] = _formatAndroidPhySupport(phySupport);
        } catch (e) {
          info['phySupport'] = null;
          info['phySupportDetails'] = 'PHY support query failed';
        }
      } else {
        // For non-Android platforms
        info['phySupportDetails'] = 'PHY support: Not available on this platform';
      }
      
    } catch (e) {
      info['error'] = 'Failed to get Bluetooth info: $e';
    }
    
    return info;
  }

  /// Format Android PHY support information for display
  String _formatAndroidPhySupport(dynamic phySupport) {
    if (phySupport == null) {
      return 'No PHY support information';
    }
    
    // The phySupport is a list of PHY types on Android
    // We'll format it as a string since we can't use the enum on other platforms
    try {
      final List<dynamic> phyList = phySupport as List<dynamic>;
      if (phyList.isEmpty) {
        return 'No PHY support available';
      }
      
      final supportedPhys = phyList.map((phy) {
        // Convert the PHY enum to string representation
        final phyString = phy.toString();
        if (phyString.contains('le1m')) {
          return 'LE 1M';
        } else if (phyString.contains('le2m')) {
          return 'LE 2M';
        } else if (phyString.contains('leCoded')) {
          return 'LE Coded';
        } else {
          return phyString;
        }
      }).toList();
      
      return 'Supported PHYs: ${supportedPhys.join(', ')}';
    } catch (e) {
      return 'PHY support information unavailable';
    }
  }

  /// Release a subscriber from the service
  void releaseSubscriber() {
    _subscriberCount--;
    if (_subscriberCount <= 0) {
      _dispose();
    }
  }
  
  /// Internal dispose method
  void _dispose() {
    _adapterSubscription?.cancel();
    _adapterSubscription = null;
    _stateController?.close();
    _stateController = null;
    _isInitialized = false;
    _subscriberCount = 0;
  }
  
  /// Force dispose (for testing or emergency cleanup)
  void forceDispose() {
    _dispose();
  }
}