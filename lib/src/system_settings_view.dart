import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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
    if (_settings == null) return [];
    
    final entries = _settings!.entries.toList()
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
          child: ListView.builder(
            itemCount: filteredSettings.length,
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

  String _formatValue(dynamic val) {
    if (val == null) return 'null';
    
    if (val is bool) {
      return val ? 'true' : 'false';
    }
    
    if (val is num) {
      return val.toString();
    }
    
    if (val is String) {
      return val.isEmpty ? '(empty)' : val;
    }
    
    if (val is List) {
      if (val.isEmpty) return '[]';
      try {
        return const JsonEncoder.withIndent('  ').convert(val);
      } catch (_) {
        return val.toString();
      }
    }
    
    if (val is Map) {
      if (val.isEmpty) return '{}';
      try {
        return const JsonEncoder.withIndent('  ').convert(val);
      } catch (_) {
        return val.toString();
      }
    }
    
    return val.toString();
  }

  Widget _buildValueWidget(BuildContext context) {
    if (value is bool) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value 
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value ? 'true' : 'false',
          style: TextStyle(
            color: value ? Colors.green : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    if (value is num) {
      return Text(
        _formatValue(value),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontFamily: 'monospace',
        ),
      );
    }
    
    if (value is String && value.isNotEmpty) {
      return Text(
        value.length > 30 ? '${value.substring(0, 30)}...' : value,
        style: const TextStyle(fontFamily: 'monospace'),
      );
    }
    
    if (value is List || value is Map) {
      final itemCount = value is List ? value.length : (value as Map).length;
      final type = value is List ? 'array' : 'object';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$type ($itemCount items)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontSize: 12,
          ),
        ),
      );
    }
    
    return Text(
      _formatValue(value),
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  settingKey,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  final formattedValue = _formatValue(value);
                  Clipboard.setData(ClipboardData(
                    text: '$settingKey: $formattedValue',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              _formatValue(value),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsExpansion = value is List || value is Map;
    
    return ListTile(
      title: Text(
        settingKey,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      ),
      trailing: _buildValueWidget(context),
      onTap: needsExpansion || (value is String && value.length > 30)
          ? () => _showDetailDialog(context)
          : null,
    );
  }
}