// Export the shared types
export 'wifi_permissions_types.dart';

// Export platform-specific implementations
export "wifi_permissions_stub.dart"
    if (dart.library.io) "wifi_permissions_native.dart"
    if (dart.library.js_interop) "wifi_permissions_web.dart"
    if (dart.library.js) "wifi_permissions_web.dart";
