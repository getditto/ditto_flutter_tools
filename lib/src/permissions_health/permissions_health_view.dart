import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_service.dart' show BluetoothStatusService;
import 'bluetooth_permissions_service.dart';
import 'wifi_permissions_cross_platform.dart';

class PermissionsHealthView extends StatefulWidget {
  const PermissionsHealthView({super.key});

  @override
  State<PermissionsHealthView> createState() => _PermissionsHealthViewState();
}

class _PermissionsHealthViewState extends State<PermissionsHealthView> {
  late final BluetoothStatusService _bluetoothService;
  late final BluetoothPermissionsService _permissionsService;

  PermissionStatus? _bluetoothPermissionStatus;
  BluetoothAdapterState? _bluetoothAdapterState;
  bool? _isBluetoothSupported;
  Map<String, dynamic>? _detailedBluetoothInfo;
  WifiPermissionResult? _wifiPermissionResult;
  WifiAwarePermissionResult? _wifiAwarePermissionResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bluetoothService = BluetoothStatusService();
    _permissionsService = BluetoothPermissionsService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    if (kIsWeb) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Initialize Bluetooth service
      await _bluetoothService.initialize();

      // Small delay to ensure Bluetooth service is fully ready on iOS
      await Future.delayed(const Duration(milliseconds: 100));

      // Get initial states
      await _loadInitialData();

      // Listen to Bluetooth adapter state changes
      _bluetoothService.adapterStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _bluetoothAdapterState = state;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final permissionStatus =
          await _permissionsService.getBluetoothPermissionStatus();
      final adapterState = await _bluetoothService.getFreshAdapterState();
      final isSupported = await _bluetoothService.isBluetoothSupported();
      final detailedInfo = await _bluetoothService.getDetailedBluetoothInfo();
      
      // Load WiFi permission data
      final wifiResult = await checkWifiPermissions();
      final wifiAwareResult = await checkWifiAwarePermissions();

      if (mounted) {
        setState(() {
          _bluetoothPermissionStatus = permissionStatus;
          _bluetoothAdapterState = adapterState;
          _isBluetoothSupported = isSupported;
          _detailedBluetoothInfo = detailedInfo;
          _wifiPermissionResult = wifiResult;
          _wifiAwarePermissionResult = wifiAwareResult;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadInitialData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _bluetoothService.releaseSubscriber();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebNotSupported();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBluetoothPermissionCard(),
        const SizedBox(height: 16),
        _buildBluetoothStatusCard(),
        const SizedBox(height: 16),
        _buildWifiStatusCard(),
        if (Platform.isAndroid) ...[
          const SizedBox(height: 16),
          _buildWifiAwareStatusCard(),
        ],
      ],
    );
  }

  Widget _buildBluetoothPermissionCard() {
    final isGranted = _bluetoothPermissionStatus == PermissionStatus.granted;
    final statusText = _getPermissionStatusText(_bluetoothPermissionStatus);

    return _buildCard(
      title: 'Bluetooth Permission',
      statusText: 'Permission: $statusText',
      isHealthy: isGranted,
      showActionButton: false,
      actionButtonText: 'Grant Permission',
    );
  }

  Widget _buildBluetoothStatusCard() {
    final detailedInfo = _detailedBluetoothInfo;
    final detailTexts = <String>[];

    // Add detailed information if available
    if (detailedInfo != null) {
      if (Platform.isAndroid) {
        detailTexts.add('Warning: Android Emulators might display enabled when they have no physical Bluetooth adapter.');
      }

      // Add error information if any
      if (detailedInfo.containsKey('error')) {
        detailTexts.add('Error: ${detailedInfo['error']}');
      }
    }

    if (_isBluetoothSupported == false) {
      return _buildCard(
        title: 'Bluetooth Status',
        statusText: 'Bluetooth: Unsupported',
        isHealthy: false,
        showActionButton: false,
        detailTexts: detailTexts,
      );
    }

    final isEnabled = _bluetoothAdapterState == BluetoothAdapterState.on;
    final statusText = _bluetoothService.bluetoothStateString;

    return _buildCard(
      title: 'Bluetooth Status',
      statusText: 'Bluetooth: $statusText',
      isHealthy: isEnabled,
      showActionButton: false,
      actionButtonText: 'Enable Bluetooth',
      detailTexts: detailTexts,
    );
  }

  Widget _buildWifiStatusCard() {
    final wifiResult = _wifiPermissionResult;
    
    if (wifiResult == null) {
      return _buildCard(
        title: 'Wi-Fi Status',
        statusText: 'Wi-Fi: Loading...',
        isHealthy: false,
        showActionButton: false,
      );
    }

    final isConfigured = wifiResult.status == WifiPermissionStatus.enabled;
    final isNotSupported = wifiResult.status == WifiPermissionStatus.notSupported;
    
    String statusText;
    bool isHealthy;
    
    if (isNotSupported) {
      statusText = 'Wi-Fi: Platform not supported';
      isHealthy = false;
    } else if (isConfigured) {
      statusText = 'Wi-Fi: Enabled';
      isHealthy = true;
    } else {
      statusText = 'Wi-Fi: Not configured';
      isHealthy = false;
    }

    return _buildCard(
      title: 'Wi-Fi Status',
      statusText: statusText,
      isHealthy: isHealthy,
      showActionButton: false,
      detailTexts: wifiResult.message.isNotEmpty ? [wifiResult.message] : null,
    );
  }

  Widget _buildWifiAwareStatusCard() {
    final wifiAwareResult = _wifiAwarePermissionResult;
    
    if (wifiAwareResult == null) {
      return _buildCard(
        title: 'Wi-Fi Aware Status',
        statusText: 'Wi-Fi Aware: Loading...',
        isHealthy: false,
        showActionButton: false,
      );
    }

    final isConfigured = wifiAwareResult.status == WifiPermissionStatus.enabled;
    final isNotSupported = wifiAwareResult.status == WifiPermissionStatus.notSupported;
    
    String statusText;
    bool isHealthy;
    
    if (isNotSupported) {
      statusText = 'Wi-Fi Aware: Platform not supported';
      isHealthy = false;
    } else if (isConfigured) {
      statusText = 'Wi-Fi Aware: Enabled';
      isHealthy = true;
    } else {
      statusText = 'Wi-Fi Aware: Not configured';
      isHealthy = false;
    }

    return _buildCard(
      title: 'Wi-Fi Aware Status',
      statusText: statusText,
      isHealthy: isHealthy,
      showActionButton: false,
      detailTexts: wifiAwareResult.message.isNotEmpty ? [wifiAwareResult.message] : null,
    );
  }

  Widget _buildCard({
    required String title,
    required String statusText,
    required bool isHealthy,
    required bool showActionButton,
    String? actionButtonText,
    VoidCallback? onActionPressed,
    List<String>? detailTexts,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  isHealthy ? Icons.check_circle : Icons.warning,
                  color: isHealthy ? Colors.green : Colors.orange,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (detailTexts != null && detailTexts.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...detailTexts.map((detail) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      detail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )),
            ],
            if (showActionButton && actionButtonText != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPermissionStatusText(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Allowed Always';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
      case null:
        return 'Unknown';
    }
  }

  Widget _buildWebNotSupported() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.web,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Not Supported on Web',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Permissions health monitoring is not supported on web platforms. This feature is available on iOS, Android, macOS, Linux, and Windows.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
