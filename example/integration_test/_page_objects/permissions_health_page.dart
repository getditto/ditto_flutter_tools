import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget text labels rendered by the permissions-health screen and the main
/// list view. Centralized here so renames in production source break in one
/// place rather than across multiple test bodies.
class PermissionsHealthLabels {
  static const tileText = 'Permissions Health';
  static const screenHeaderText = 'Permissions Health';
  static const bluetoothPermissionCard = 'Bluetooth Permission';
  static const bluetoothStatusCard = 'Bluetooth Status';
}

/// Valid permission state strings the screen may render. The test asserts
/// that the rendered state is one of these — it does not assert a specific
/// state because that depends on the simulator/device's Bluetooth-permission
/// configuration at test time.
const List<String> validPermissionStates = [
  'Permission: Allowed Always',
  'Permission: Denied',
  'Permission: Restricted',
  'Permission: Limited',
  'Permission: Permanently Denied',
  'Permission: Provisional',
];

/// Valid Bluetooth state strings the screen may render. As with permissions,
/// the rendered state depends on the simulator/device.
const List<String> validBluetoothStates = [
  'Bluetooth: Enabled',
  'Bluetooth: Disabled',
  'Bluetooth: Unavailable',
  'Bluetooth: Unauthorized',
  'Bluetooth: Turning On',
  'Bluetooth: Turning Off',
  'Bluetooth: Unknown',
  'Bluetooth: Unsupported',
];

/// Page-object helpers for navigating and asserting against the
/// permissions-health screen.
extension PermissionsHealthPage on WidgetTester {
  Future<void> tapPermissionsHealthTile() async {
    final tile = find.text(PermissionsHealthLabels.tileText);
    expect(tile, findsOneWidget);
    await tap(tile);
    await pumpAndSettle();
  }

  Future<void> tapBackToMainScreen() async {
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tap(backButton);
    await pumpAndSettle();
  }

  void expectPermissionsHealthScreenLoaded() {
    // The screen header may render alongside other widgets that show the
    // same string (e.g. an AppBar back-stack indicator), so use
    // `findsAtLeastNWidgets(1)` rather than `findsOneWidget`. This matches
    // the original test's matcher choice for the same string.
    expect(
      find.text(PermissionsHealthLabels.screenHeaderText),
      findsAtLeastNWidgets(1),
      reason: 'expected screen header on permissions health screen',
    );
    expect(
      find.text(PermissionsHealthLabels.bluetoothPermissionCard),
      findsOneWidget,
      reason: 'expected Bluetooth Permission card on permissions health screen',
    );
    expect(
      find.text(PermissionsHealthLabels.bluetoothStatusCard),
      findsOneWidget,
      reason: 'expected Bluetooth Status card on permissions health screen',
    );
  }

  void expectMainScreenShowsPermissionsHealthEntry() {
    expect(
      find.text(PermissionsHealthLabels.tileText),
      findsOneWidget,
      reason: 'expected Permissions Health tile on main screen',
    );
    expect(
      find.text(PermissionsHealthLabels.bluetoothPermissionCard),
      findsNothing,
      reason: 'permissions health cards should not be on main screen',
    );
    expect(
      find.text(PermissionsHealthLabels.bluetoothStatusCard),
      findsNothing,
      reason: 'permissions health cards should not be on main screen',
    );
  }

  /// Asserts that one of [validPermissionStates] is rendered on screen.
  /// Returns the matched state for diagnostic logging.
  String expectValidPermissionState() {
    for (final state in validPermissionStates) {
      if (find.text(state).evaluate().isNotEmpty) {
        return state;
      }
    }
    fail(
      'no valid permission state found on screen; expected one of '
      '$validPermissionStates',
    );
  }

  /// Asserts that one of [validBluetoothStates] is rendered on screen.
  /// Returns the matched state for diagnostic logging.
  String expectValidBluetoothState() {
    for (final state in validBluetoothStates) {
      if (find.text(state).evaluate().isNotEmpty) {
        return state;
      }
    }
    fail(
      'no valid Bluetooth state found on screen; expected one of '
      '$validBluetoothStates',
    );
  }
}
