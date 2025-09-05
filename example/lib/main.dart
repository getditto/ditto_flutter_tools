// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:example/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:beamer/beamer.dart';

import 'services/ditto_service.dart';
import 'routing/app_beamer.dart';

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
    return const DittoExample();
  }

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
  BeamerDelegate? _beamerDelegate;
  bool _isInitializing = true;
  String? _errorMessage;

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

      final beamerDelegate = AppBeamer.createDelegate(
        dittoService: dittoService,
        subscriptionService: subscriptionService,
      );

      setState(() {
        _beamerDelegate = beamerDelegate;
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

    final beamerDelegate = _beamerDelegate;
    if (beamerDelegate == null) {
      return _buildError(_errorMessage);
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ditto Tools',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      routerDelegate: beamerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }

  Widget get _loading => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
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
      theme: _lightTheme,
      darkTheme: _darkTheme,
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

