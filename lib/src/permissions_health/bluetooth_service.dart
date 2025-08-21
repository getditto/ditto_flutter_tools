import 'dart:async';
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
      
      // On iOS, the initial state might be unknown, so wait for a valid state
      var state = currentAdapterState;
      if (state == BluetoothAdapterState.unknown) {
        // Wait a bit for the state to be determined
        await Future.delayed(const Duration(milliseconds: 200));
        state = currentAdapterState;
      }
      
      return state;
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
    } catch (e) {
      info['error'] = 'Failed to get Bluetooth info: $e';
    }
    
    return info;
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