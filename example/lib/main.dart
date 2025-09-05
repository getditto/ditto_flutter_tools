// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:ditto_flutter_tools/ditto_flutter_tools.dart';
import 'package:example/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/ditto_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //load the .env file to get portal information
  await dotenv.load(fileName: ".env");

  runApp(const DittoApp());
}

class DittoApp extends StatelessWidget {
  const DittoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ditto Tools',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      home: const DittoExample(),
    );
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.blue,
      secondary: Colors.green,
      tertiary: Colors.blueGrey,
      error: Colors.red,
      surface: Colors.white,
      surfaceContainerHighest: Colors.grey[50],
      outline: Colors.grey[300],
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Colors.blue[300],
      secondary: Colors.green[300],
      tertiary: Colors.blueGrey[400],
      error: Colors.red[300],
      surface: Colors.grey[900],
      surfaceContainerHighest: Colors.grey[850],
      outline: Colors.grey[600],
    ),
  );
}

class DittoExample extends StatefulWidget {
  const DittoExample({super.key});

  @override
  State<DittoExample> createState() => _DittoExampleState();
}

class _DittoExampleState extends State<DittoExample> {
  //load in values from env file
  final appID = dotenv.env['DITTO_APP_ID'] ??
      (throw Exception("DITTO_APP_ID not found in .env file"));
  final token = dotenv.env['DITTO_TOKEN'] ??
      (throw Exception("DITTO_TOKEN not found in .env file"));
  final authUrl = dotenv.env['DITTO_AUTH_URL'] ??
      (throw Exception("DITTO_AUTH_URL not found in .env file"));
  final websocketUrl = dotenv.env['DITTO_WEBSOCKET_URL'] ??
      (throw Exception("DITTO_WEBSOCKET_URL not found in .env file"));
  DittoService? _dittoService;
  SubscriptionService? _subscriptionService;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initDitto();
  }

  Future<void> _initDitto() async {
    try {
      // Setup ditto provider
      final dittoService = DittoService();
      await dittoService.initialize(appID, token, authUrl, websocketUrl);

      // Only create subscription service after Ditto is fully initialized
      final subscriptionService = SubscriptionService(dittoService);

      setState(() {
        _dittoService = dittoService;
        _subscriptionService = subscriptionService;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      print('Error initializing Ditto: $e');
      setState(() {
        _isInitializing = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _loading;
    }

    final dittoService = _dittoService;
    if (dittoService == null) {
      return _buildError(_errorMessage);
    }

    return _MainListView(
        dittoService: dittoService, subscriptionService: _subscriptionService!);
  }

  Widget get _loading => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DittoApp._lightTheme,
        darkTheme: DittoApp._darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          appBar: AppBar(title: const Text("Ditto Tools")),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Initializing Ditto..."),
              ],
            ),
          ),
        ),
      );

  Widget _buildError(String? errorMessage) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DittoApp._lightTheme,
      darkTheme: DittoApp._darkTheme,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Ditto Tools")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Failed to initialize Ditto",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage ?? "Unknown error occurred",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initDitto,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainListView extends StatelessWidget {
  final DittoService dittoService;
  final SubscriptionService subscriptionService;

  const _MainListView({
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar: AppBar(title: const Text("Peers List")),
                            body: PeerListView(ditto: dittoService.ditto),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar: AppBar(title: const Text("Sync Status")),
                            body: SyncStatusView(
                              ditto: dittoService.ditto,
                              subscriptions: subscriptionService.subscriptions,
                            ),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar: AppBar(title: const Text("Peer Sync Status")),
                            body: PeerSyncStatusView(ditto: dittoService.ditto),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar:
                                AppBar(title: const Text("Permissions Health")),
                            body: const PermissionsHealthView(),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar: AppBar(title: const Text("Disk Usage")),
                            body: DiskUsageView(ditto: dittoService.ditto!),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                          child: Scaffold(
                            appBar:
                                AppBar(title: const Text("System Settings")),
                            body:
                                SystemSettingsView(ditto: dittoService.ditto!),
                          ),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
