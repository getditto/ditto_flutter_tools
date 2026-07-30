import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:ditto_live/ditto_live.dart';
import 'package:permission_handler/permission_handler.dart';

class DittoService {
  Ditto? _ditto;
  bool get isInitialized => _ditto != null;

  /// The Ditto instance used for database operations
  /// Throws StateError if Ditto hasn't been initialized yet
  Ditto get ditto {
    if (_ditto == null) {
      throw StateError(
          'Ditto has not been initialized. Call initialize() first.');
    }
    return _ditto!;
  }

  /// Initializes the Ditto instance with necessary permissions and configuration.
  /// https://docs.ditto.live/sdk/latest/install-guides/flutter#step-3-import-and-initialize-the-ditto-sdk
  ///
  /// This function:
  /// 1. Requests required Bluetooth and WiFi permissions on non-web platforms
  /// 2. Initializes the Ditto SDK
  /// 3. Sets up identity with the provided token
  /// 4. Starts sync and updates the app state with the configured Ditto instance
  Future<void> initialize(
    String appId,
    String token,
    String authUrl,
  ) async {
    // Note: macOS handles Bluetooth permissions differently via entitlements
    if (!kIsWeb &&
        (Ditto.currentPlatform == SupportedPlatform.android ||
            Ditto.currentPlatform == SupportedPlatform.ios)) {
      // Request permissions and check their status
      await [
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.nearbyWifiDevices,
        Permission.bluetoothScan
      ].request();
    }
    // Initialize Ditto first - this must be called before any other Ditto operations
    await Ditto.init();

    // Now we can safely configure logging
    DittoLogger.isEnabled = false;
    DittoLogger.minimumLogLevel = LogLevel.error;
    DittoLogger.customLogCallback = (level, message) {
      print("[$level] => $message");
    };

    final config = DittoConfig(
      databaseID: appId,
      connect: DittoConfigConnectServer(url: authUrl),
    );

    _ditto = await Ditto.open(config);

    if (!isInitialized) {
      throw Exception("Failed to initialize Ditto");
    }

    // Set up auth expiration handler before starting sync
    await ditto.auth.setExpirationHandler((ditto, timeUntilExpiration) {
      ditto.auth.login(
        token: token,
        provider: Authenticator.developmentProvider,
      );
    });

    // Perform initial login
    await ditto.auth.login(
      token: token,
      provider: Authenticator.developmentProvider,
    );

    // Setup device information for peer listing
    ditto.deviceName = "Flutter (${ditto.deviceName})";

    ditto.sync.start();
  }
}
