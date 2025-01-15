import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DqlBuilder extends StatefulWidget {
  final Ditto ditto;
  final String query;
  final Map<String, dynamic>? queryArgs;
  final Widget Function(BuildContext, QueryResult) builder;
  final Widget? loading;

  const DqlBuilder({
    super.key,
    required this.ditto,
    required this.query,
    this.queryArgs,
    required this.builder,
    this.loading,
  });

  @override
  State<DqlBuilder> createState() => _DqlBuilderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty("ditto", ditto));
  }
}

class _DqlBuilderState extends State<DqlBuilder> {
  late StoreObserver _observer;
  late SyncSubscription _subscription;
  QueryResult? _result;

  @override
  void initState() {
    super.initState();

    final observer = widget.ditto.store.registerObserver(
      widget.query,
      arguments: widget.queryArgs ?? {},
      onChange: (result) {
        setState(() => _result = result);
      },
    );

    final subscription = widget.ditto.sync.registerSubscription(
      widget.query,
      arguments: widget.queryArgs ?? {},
    );

    setState(() {
      _observer = observer;
      _subscription = subscription;
    });
  }

  @override
  void didUpdateWidget(covariant DqlBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isSame = widget.query == oldWidget.query &&
        widget.queryArgs == oldWidget.queryArgs;

    if (!isSame) {
      _observer.cancel();
      _subscription.cancel();

      final observer = widget.ditto.store.registerObserver(
        widget.query,
        arguments: widget.queryArgs ?? {},
      );

      final subscription = widget.ditto.sync.registerSubscription(
        widget.query,
        arguments: widget.queryArgs ?? {},
      );

      setState(() {
        _observer = observer;
        _subscription = subscription;
      });
    }
  }

  @override
  void dispose() {
    _observer.cancel();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.loading ?? _defaultLoading;
    if (_result == null) return placeholder;
    return widget.builder(context, _result!);
  }
}

const _defaultLoading = Center(child: CircularProgressIndicator());
