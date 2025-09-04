import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

class SystemSettingsView extends StatefulWidget {
  final Ditto ditto;
  
  const SystemSettingsView({super.key, required this.ditto});

  @override
  State<SystemSettingsView> createState() => _SystemSettingsViewState();
}

class _SystemSettingsViewState extends State<SystemSettingsView> {
  Map<String, dynamic>? _settings;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSystemSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSystemSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await widget.ditto.store.execute('SHOW ALL');
      
      if (result.items.isNotEmpty) {
        // The SHOW ALL command returns a single item with all settings as a Map
        final settings = Map<String, dynamic>.from(result.items.first.value);
        
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _settings = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MapEntry<String, dynamic>> _getFilteredSettings() {
    final settings = _settings;
    if (settings == null) return [];
    
    final entries = settings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (_searchQuery.isEmpty) {
      return entries;
    }

    return entries.where((entry) {
      final key = entry.key.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final value = entry.value.toString().toLowerCase();
      return key.contains(query) || value.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading system settings...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load system settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadSystemSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredSettings = _getFilteredSettings();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredSettings.length} settings',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton.icon(
                onPressed: _loadSystemSettings,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            itemCount: filteredSettings.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final entry = filteredSettings[index];
              return _SettingTile(
                settingKey: entry.key,
                value: entry.value,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String settingKey;
  final dynamic value;

  const _SettingTile({
    required this.settingKey,
    required this.value,
  });

  Widget _buildSimpleValue() {
    if (value is Map || value is List) {
      return ExpansionTile(
        title: Text(settingKey),
        subtitle: Text(value.toString()),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              value.toString(),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      );
    }

    return ListTile(
      title: Text(settingKey),
      subtitle: Text(value.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSimpleValue();
  }
}