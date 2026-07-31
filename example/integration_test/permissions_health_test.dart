import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart' as app;
import 'package:ditto_flutter_tools/src/permissions_health/bluetooth_service.dart';

import '_page_objects/permissions_health_page.dart';

/// Per-test timeout. The default `flutter test` timeout is 10 minutes per
/// test; that's wildly excessive for these tests, which boot the app, tap
/// through one navigation flow, and assert. A hung test under the default
/// would burn 30 minutes of CI on this single file.
const Duration permissionsHealthTestTimeout = Duration(seconds: 30);

/// Time given to Bluetooth service singleton cleanup between tests. The
/// service has async dispose paths that don't currently expose completion;
/// a follow-up could add a probe-able signal to replace this fixed wait.
const Duration bluetoothServiceCleanupGrace = Duration(milliseconds: 500);

void main() {
  group('Permissions Health Integration Tests', () {
    tearDown(() async {
      // Force cleanup of the Bluetooth service singleton to prevent test
      // interference. The forceDispose path doesn't currently emit a
      // completion signal we can probe, so the fixed wait stays — see retro.
      BluetoothStatusService().forceDispose();
      await Future<void>.delayed(bluetoothServiceCleanupGrace);
    });

    testWidgets(
      'permissions health screen loads',
      timeout: const Timeout(permissionsHealthTestTimeout),
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        await tester.tapPermissionsHealthTile();
        tester.expectPermissionsHealthScreenLoaded();
      },
    );

    testWidgets(
      'permissions health screen displays a valid Bluetooth permission and status',
      timeout: const Timeout(permissionsHealthTestTimeout),
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        await tester.tapPermissionsHealthTile();
        tester.expectPermissionsHealthScreenLoaded();

        // The exact rendered state depends on the simulator/device's
        // permission configuration. Test asserts only that *some* valid
        // state is rendered, not which one.
        tester.expectValidPermissionState();
        tester.expectValidBluetoothState();
      },
    );

    testWidgets(
      'permissions health screen survives multiple navigation cycles (regression)',
      timeout: const Timeout(permissionsHealthTestTimeout),
      (tester) async {
        // This is the test the file exists for: the original bug was that
        // navigating away and back from permissions health crashed with
        // stream controller errors. Two full nav cycles exercise the
        // lifecycle path that was previously broken.
        app.main();
        await tester.pumpAndSettle();

        await tester.tapPermissionsHealthTile();
        tester.expectPermissionsHealthScreenLoaded();

        // Cycle 1: back, forward.
        await tester.tapBackToMainScreen();
        tester.expectMainScreenShowsPermissionsHealthEntry();
        await tester.tapPermissionsHealthTile();
        tester.expectPermissionsHealthScreenLoaded();
        tester.expectValidPermissionState();
        tester.expectValidBluetoothState();

        // Cycle 2: back, forward — confirms the lifecycle fix is stable
        // across repeated navigations, not just the first pair.
        await tester.tapBackToMainScreen();
        tester.expectMainScreenShowsPermissionsHealthEntry();
        await tester.tapPermissionsHealthTile();
        tester.expectPermissionsHealthScreenLoaded();
      },
    );
  });
}
