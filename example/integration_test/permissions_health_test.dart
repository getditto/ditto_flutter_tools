import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart' as app;
import 'package:ditto_flutter_tools/src/permissions_health/bluetooth_service.dart';

void main() {
  group('Permissions Health Integration Tests', () {
    
    // Clean up between tests to prevent state interference
    tearDown(() async {
      // Force cleanup of the Bluetooth service singleton to prevent test interference
      BluetoothStatusService().forceDispose();
      // Allow for cleanup time
      await Future.delayed(const Duration(milliseconds: 500));
    });

    testWidgets('should display permissions health screen and handle navigation lifecycle bug fix', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for Ditto to initialize
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find and tap on Permissions Health item
      final permissionsHealthTile = find.text('Permissions Health');
      expect(permissionsHealthTile, findsOneWidget);
      
      print('✅ Found Permissions Health tile - tapping...');
      await tester.tap(permissionsHealthTile);
      await tester.pumpAndSettle();

      // Verify we're on the permissions health screen
      expect(find.text('Permissions Health'), findsAtLeastNWidgets(1));
      
      // Wait for the permissions health view to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check that Bluetooth Permission card exists
      expect(find.text('Bluetooth Permission'), findsOneWidget);
      print('✅ Found Bluetooth Permission card');
      
      // Check that Bluetooth Status card exists  
      expect(find.text('Bluetooth Status'), findsOneWidget);
      print('✅ Found Bluetooth Status card');

      // Verify permission status text is displayed (should be one of the valid states)
      final validPermissionStates = [
        'Permission: Allowed Always',
        'Permission: Denied',
        'Permission: Restricted',
        'Permission: Limited',
        'Permission: Permanently Denied',
        'Permission: Provisional'
      ];
      
      bool foundValidPermissionState = false;
      String foundPermissionState = '';
      for (final state in validPermissionStates) {
        if (find.text(state).evaluate().isNotEmpty) {
          foundValidPermissionState = true;
          foundPermissionState = state;
          break;
        }
      }
      expect(foundValidPermissionState, isTrue, reason: 'Should find a valid permission state');
      print('✅ Found permission state: $foundPermissionState');

      // Verify Bluetooth status text is displayed (should be one of the valid states)
      final validBluetoothStates = [
        'Bluetooth: Enabled',
        'Bluetooth: Disabled', 
        'Bluetooth: Unavailable',
        'Bluetooth: Unauthorized',
        'Bluetooth: Turning On',
        'Bluetooth: Turning Off',
        'Bluetooth: Unknown',
        'Bluetooth: Unsupported'
      ];
      
      bool foundValidBluetoothState = false;
      String foundBluetoothState = '';
      for (final state in validBluetoothStates) {
        if (find.text(state).evaluate().isNotEmpty) {
          foundValidBluetoothState = true;
          foundBluetoothState = state;
          break;
        }
      }
      expect(foundValidBluetoothState, isTrue, reason: 'Should find a valid Bluetooth state');
      print('✅ Found Bluetooth state: $foundBluetoothState');

      // TEST NAVIGATION AWAY AND BACK - CRITICAL TEST FOR BUG FIX
      // This tests the original issue where navigating away and back crashed with stream controller errors
      print('🔄 Testing navigation away...');
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('Permissions Health'), findsOneWidget);
      expect(find.text('Bluetooth Permission'), findsNothing);
      expect(find.text('Bluetooth Status'), findsNothing);
      print('✅ Successfully navigated back to main screen');

      // Navigate back to permissions health screen - CRITICAL TEST FOR BUG FIX
      print('🔄 Testing navigation back to permissions health...');
      await tester.tap(permissionsHealthTile);
      await tester.pumpAndSettle();

      // Wait for reload
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify the screen loads again without crashing - THIS WAS THE ORIGINAL BUG
      expect(find.text('Bluetooth Permission'), findsOneWidget);
      expect(find.text('Bluetooth Status'), findsOneWidget);
      print('✅ Successfully navigated back to permissions health without crash!');

      // Verify states are still displayed correctly after navigation
      foundValidPermissionState = false;
      for (final state in validPermissionStates) {
        if (find.text(state).evaluate().isNotEmpty) {
          foundValidPermissionState = true;
          break;
        }
      }
      expect(foundValidPermissionState, isTrue, reason: 'Should find a valid permission state after navigation');

      foundValidBluetoothState = false;
      for (final state in validBluetoothStates) {
        if (find.text(state).evaluate().isNotEmpty) {
          foundValidBluetoothState = true;
          break;
        }
      }
      expect(foundValidBluetoothState, isTrue, reason: 'Should find a valid Bluetooth state after navigation');
      
      print('✅ All states displayed correctly after navigation - no stream controller crash!');
      
      // TEST ONE MORE NAVIGATION CYCLE TO ENSURE STABILITY 
      // This double-checks that the lifecycle management fix is working
      print('🔄 Testing additional navigation cycle for stability...');
      
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Bluetooth Permission'), findsNothing);
      expect(find.text('Bluetooth Status'), findsNothing);
      
      await tester.tap(permissionsHealthTile);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      
      expect(find.text('Bluetooth Permission'), findsOneWidget);
      expect(find.text('Bluetooth Status'), findsOneWidget);
      
      print('✅ NAVIGATION LIFECYCLE BUG FIX VERIFIED - Multiple navigation cycles work without stream controller crashes!');
    }, timeout: const Timeout(Duration(minutes: 4)));
  });
}