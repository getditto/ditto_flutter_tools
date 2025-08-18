import 'package:example/providers/ditto_provider.dart';
import 'package:ditto_live/ditto_live.dart';

class SubscriptionService {

  final  DittoProvider _dittoProvider;

  SubscriptionService(this._dittoProvider);

  List<SyncSubscription> getSubscriptions()  {
   if (_dittoProvider.ditto == null) return [];
   var taskSubscription = _dittoProvider.ditto!.sync.registerSubscription("SELECT * FROM tasks");
   var moviesSubscription = _dittoProvider.ditto!.sync.registerSubscription("SELECT * FROM movies");
   var commentsSubscription = _dittoProvider.ditto!.sync.registerSubscription("SELECT * FROM comments");
   return [taskSubscription, moviesSubscription, commentsSubscription];
  }
}