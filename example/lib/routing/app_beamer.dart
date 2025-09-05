import 'package:beamer/beamer.dart';

import '../services/ditto_service.dart';
import '../services/subscription_service.dart';
import 'beam_locations.dart';
import 'route_paths.dart';

class AppBeamer {
  static BeamerDelegate createDelegate({
    required DittoService dittoService,
    required SubscriptionService subscriptionService,
  }) {
    return BeamerDelegate(
      initialPath: RoutePaths.home,
      locationBuilder: (routeInformation, _) {
        final path = routeInformation.uri.path;
        
        if (path == RoutePaths.home || path.isEmpty || path == '/') {
          return HomeBeamLocation(
            dittoService: dittoService,
            subscriptionService: subscriptionService,
          );
        } else if (path == RoutePaths.peersList ||
            path == RoutePaths.syncStatus ||
            path == RoutePaths.peerSyncStatus) {
          return NetworkBeamLocation(
            dittoService: dittoService,
            subscriptionService: subscriptionService,
          );
        } else {
          return SystemBeamLocation(dittoService: dittoService);
        }
      },
    );
  }
}