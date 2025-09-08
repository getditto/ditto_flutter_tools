import 'package:example/services/ditto_service.dart';
import 'package:ditto_live/ditto_live.dart';

class SubscriptionService {
  final DittoService _dittoProvider;
  SubscriptionService(this._dittoProvider);

  late final _taskSub =
      _dittoProvider.ditto.sync.registerSubscription("SELECT * FROM tasks");
  late final _moviesSub =
      _dittoProvider.ditto.sync.registerSubscription("SELECT * FROM movies");
  late final _commentsSub =
      _dittoProvider.ditto.sync.registerSubscription("SELECT * FROM comments");

  List<SyncSubscription> get subscriptions =>
      [_taskSub, _moviesSub, _commentsSub];
}
