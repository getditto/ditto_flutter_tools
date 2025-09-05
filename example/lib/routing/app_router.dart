import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/ditto_service.dart';
import '../services/subscription_service.dart';
import '../widgets/main_list_view.dart';
import '../screens/peers_list_screen.dart';
import '../screens/sync_status_screen.dart';
import '../screens/peer_sync_status_screen.dart';
import '../screens/permissions_health_screen.dart';
import '../screens/disk_usage_screen.dart';
import '../screens/system_settings_screen.dart';
import 'route_paths.dart';

class AppRouter {
  static GoRouter createRouter({
    required DittoService dittoService,
    required SubscriptionService subscriptionService,
  }) {
    return GoRouter(
      initialLocation: RoutePaths.home,
      routes: [
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) => MainListView(
            dittoService: dittoService,
            subscriptionService: subscriptionService,
          ),
        ),
        GoRoute(
          path: RoutePaths.peersList,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            PeersListScreen(ditto: dittoService.ditto),
          ),
        ),
        GoRoute(
          path: RoutePaths.syncStatus,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            SyncStatusScreen(
              ditto: dittoService.ditto,
              subscriptions: subscriptionService.subscriptions,
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.peerSyncStatus,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            PeerSyncStatusScreen(ditto: dittoService.ditto),
          ),
        ),
        GoRoute(
          path: RoutePaths.permissionsHealth,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            const PermissionsHealthScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.diskUsage,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            DiskUsageScreen(ditto: dittoService.ditto),
          ),
        ),
        GoRoute(
          path: RoutePaths.systemSettings,
          pageBuilder: (context, state) => _buildPageWithSlideTransition(
            context,
            state,
            SystemSettingsScreen(ditto: dittoService.ditto),
          ),
        ),
      ],
    );
  }

  static Page<dynamic> _buildPageWithSlideTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}