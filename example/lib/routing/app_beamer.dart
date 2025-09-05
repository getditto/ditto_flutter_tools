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
        return AppBeamLocation(
          dittoService: dittoService,
          subscriptionService: subscriptionService,
        );
      },
    );
  }
}