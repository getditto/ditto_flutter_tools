export "wifi_permissions_stub.dart"
    if (dart.library.io) "wifi_permissions_native.dart"
    if (dart.library.js_interop) "wifi_permissions_web.dart";