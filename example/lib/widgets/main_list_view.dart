import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import '../services/ditto_service.dart';
import '../services/subscription_service.dart';
import '../constants/routes.dart';

class MainListView extends StatelessWidget {
  final DittoService dittoService;
  final SubscriptionService subscriptionService;

  const MainListView({
    super.key,
    required this.dittoService,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ditto Tools"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // NETWORK Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "NETWORK",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.color
                    ?.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.devices,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: const Text("Peers List"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () => Beamer.of(context).beamToNamed(peersRoute),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sync,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 20,
                    ),
                  ),
                  title: const Text("Sync Status"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () => Beamer.of(context).beamToNamed(syncStatusRoute),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_sync,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text("Peer Sync Status"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () =>
                      Beamer.of(context).beamToNamed(peerSyncStatusRoute),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // SYSTEM Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "SYSTEM",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.color
                    ?.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text("Permissions Health"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () =>
                      Beamer.of(context).beamToNamed(permissionsHealthRoute),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.storage,
                      color: Theme.of(context).colorScheme.onTertiary,
                      size: 20,
                    ),
                  ),
                  title: const Text("Disk Usage"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () => Beamer.of(context).beamToNamed(diskUsageRoute),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text("System Settings"),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () =>
                      Beamer.of(context).beamToNamed(systemSettingsRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
