import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

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

class HomeBeamLocation extends BeamLocation<BeamState> {
  final DittoService dittoService;
  final SubscriptionService subscriptionService;

  HomeBeamLocation({
    required this.dittoService,
    required this.subscriptionService,
  });

  @override
  List<String> get pathPatterns => [RoutePaths.home];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: const ValueKey('home'),
        title: 'Ditto Tools',
        child: MainListView(
          dittoService: dittoService,
          subscriptionService: subscriptionService,
        ),
      ),
    ];
  }
}

class NetworkBeamLocation extends BeamLocation<BeamState> {
  final DittoService dittoService;
  final SubscriptionService subscriptionService;

  NetworkBeamLocation({
    required this.dittoService,
    required this.subscriptionService,
  });

  @override
  List<String> get pathPatterns => [
    RoutePaths.peersList,
    RoutePaths.syncStatus,
    RoutePaths.peerSyncStatus,
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = <BeamPage>[
      BeamPage(
        key: const ValueKey('home'),
        title: 'Ditto Tools',
        child: MainListView(
          dittoService: dittoService,
          subscriptionService: subscriptionService,
        ),
      ),
    ];

    if (state.uri.path == RoutePaths.peersList) {
      pages.add(
        BeamPage(
          key: const ValueKey('peers'),
          title: 'Peers List',
          child: PeersListScreen(ditto: dittoService.ditto),
          type: BeamPageType.slideRightTransition,
        ),
      );
    } else if (state.uri.path == RoutePaths.syncStatus) {
      pages.add(
        BeamPage(
          key: const ValueKey('sync-status'),
          title: 'Sync Status',
          child: SyncStatusScreen(
            ditto: dittoService.ditto,
            subscriptions: subscriptionService.subscriptions,
          ),
          type: BeamPageType.slideRightTransition,
        ),
      );
    } else if (state.uri.path == RoutePaths.peerSyncStatus) {
      pages.add(
        BeamPage(
          key: const ValueKey('peer-sync-status'),
          title: 'Peer Sync Status',
          child: PeerSyncStatusScreen(ditto: dittoService.ditto),
          type: BeamPageType.slideRightTransition,
        ),
      );
    }

    return pages;
  }
}

class SystemBeamLocation extends BeamLocation<BeamState> {
  final DittoService dittoService;

  SystemBeamLocation({required this.dittoService});

  @override
  List<String> get pathPatterns => [
    RoutePaths.permissionsHealth,
    RoutePaths.diskUsage,
    RoutePaths.systemSettings,
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = <BeamPage>[
      BeamPage(
        key: const ValueKey('home'),
        title: 'Ditto Tools',
        child: MainListView(
          dittoService: dittoService,
          subscriptionService: SubscriptionService(dittoService),
        ),
      ),
    ];

    if (state.uri.path == RoutePaths.permissionsHealth) {
      pages.add(
        const BeamPage(
          key: ValueKey('permissions-health'),
          title: 'Permissions Health',
          child: PermissionsHealthScreen(),
          type: BeamPageType.slideRightTransition,
        ),
      );
    } else if (state.uri.path == RoutePaths.diskUsage) {
      pages.add(
        BeamPage(
          key: const ValueKey('disk-usage'),
          title: 'Disk Usage',
          child: DiskUsageScreen(ditto: dittoService.ditto),
          type: BeamPageType.slideRightTransition,
        ),
      );
    } else if (state.uri.path == RoutePaths.systemSettings) {
      pages.add(
        BeamPage(
          key: const ValueKey('system-settings'),
          title: 'System Settings',
          child: SystemSettingsScreen(ditto: dittoService.ditto),
          type: BeamPageType.slideRightTransition,
        ),
      );
    }

    return pages;
  }
}

