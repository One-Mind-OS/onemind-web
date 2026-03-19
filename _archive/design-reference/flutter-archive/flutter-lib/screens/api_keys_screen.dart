import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

/// API Keys Screen - API Key Management
/// Manage API keys for external services with secure storage
/// Solar Punk Tactical Theme
class ApiKeysScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ApiKeysScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  List<Map<String, dynamic>> _apiKeys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final keys = await ApiService.listApiKeys();
      setState(() {
        _apiKeys = keys;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createApiKey(String name, String key, {String? description, String? icon, String? color}) async {
    try {
      await ApiService.createApiKey(
        name: name,
        key: key,
        description: description,
        icon: icon,
        color: color,
      );
      _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API key "$name" created successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create API key: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateApiKey(String keyId, Map<String, dynamic> updates) async {
    try {
      await ApiService.updateApiKey(keyId, updates);
      _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update API key: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteApiKey(String keyId, String keyName) async {
    try {
      await ApiService.deleteApiKey(keyId);
      _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API key "$keyName" deleted'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete API key: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF5F7F5);
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    final activeCount = _apiKeys.where((k) => k['is_active'] == true).length;

    final body = Column(
      children: [
        // Header (only show active count or filter bar if embedded? No, let's keep the header style consistent but remove the back button implication)
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentOrange, const Color(0xFFEA580C)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: accentOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.vpn_key, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API Keys', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Secure credential management', style: TextStyle(color: mutedText, fontSize: 12)),
                  ],
                ),
              ),
              _statChip('$activeCount', 'Active', accentGreen),
              const SizedBox(width: 8),
              _statChip('${_apiKeys.length}', 'Total', accentBlue),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.refresh, color: textColor),
                onPressed: _loadApiKeys,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: accentGreen))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading API keys', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_error!, style: TextStyle(color: mutedText), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadApiKeys,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: FilledButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.black),
                          ),
                        ],
                      ),
                    )
                  : _apiKeys.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.vpn_key_off, size: 64, color: mutedText),
                              const SizedBox(height: 16),
                              Text('No API keys yet', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Add your first API key to get started', style: TextStyle(color: mutedText)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _apiKeys.length,
                          itemBuilder: (context, index) {
                            final key = _apiKeys[index];
                            return _apiKeyCard(key, cardBg, borderColor, accentGreen, accentOrange, accentBlue, textColor, mutedText);
                          },
                        ),
        ),
      ],
    );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: bg,
        body: body,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddKeyDialog(),
          backgroundColor: accentGreen,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add),
          label: const Text('Add Key', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddKeyDialog(),
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Key', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _apiKeyCard(Map<String, dynamic> apiKey, Color cardBg, Color borderColor, 
      Color accentGreen, Color accentOrange, Color accentBlue, Color textColor, Color mutedText) {
    final isActive = apiKey['is_active'] == true;
    final keyPreview = apiKey['key_preview'] as String? ?? '****';
    final usage = apiKey['usage_count'] as int? ?? 0;

    // Default icon/color if not provided
    final IconData icon = _getIconFromName(apiKey['icon'] as String?);
    final Color color = _getColorFromHex(apiKey['color'] as String?) ?? accentBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? accentGreen.withValues(alpha: 0.3) : borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(apiKey['name'] as String, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isActive ? accentGreen : Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(color: isActive ? accentGreen : Colors.red, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: mutedText.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(keyPreview, style: TextStyle(color: mutedText, fontSize: 11, fontFamily: 'monospace')),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: keyPreview));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied ${apiKey['name']} key preview'), duration: const Duration(seconds: 2)),
                              );
                            },
                            child: Icon(Icons.copy, size: 16, color: mutedText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: mutedText),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(isActive ? Icons.pause : Icons.play_arrow, size: 18),
                        const SizedBox(width: 8),
                        Text(isActive ? 'Disable' : 'Enable'),
                      ]),
                    ),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                  onSelected: (value) async {
                    final keyId = apiKey['id'] as String;
                    final keyName = apiKey['name'] as String;

                    if (value == 'toggle') {
                      await _updateApiKey(keyId, {'is_active': !isActive});
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete API Key'),
                          content: Text('Are you sure you want to delete "$keyName"? This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deleteApiKey(keyId, keyName);
                      }
                    }
                  },
                ),
              ],
            ),
            if (usage > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.analytics, size: 12, color: mutedText),
                  const SizedBox(width: 4),
                  Text('Used $usage times', style: TextStyle(color: mutedText, fontSize: 10)),
                ],
              ),
            ],
            if (apiKey['last_used'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: mutedText),
                  const SizedBox(width: 4),
                  Text('Last used ${_formatTime(DateTime.parse(apiKey['last_used']))}', style: TextStyle(color: mutedText, fontSize: 10)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'auto_awesome': return Icons.auto_awesome;
      case 'psychology': return Icons.psychology;
      case 'diamond': return Icons.diamond;
      case 'cloud': return Icons.cloud;
      case 'bolt': return Icons.bolt;
      case 'home': return Icons.home;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'search': return Icons.search;
      default: return Icons.vpn_key;
    }
  }

  Color? _getColorFromHex(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  void _showAddKeyDialog() {
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
        final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
        final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
        final accentGreen = const Color(0xFF4ADE80);

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add API Key', style: TextStyle(color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g., OpenAI, Anthropic',
                  labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentGreen)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keyController,
                style: TextStyle(color: textColor),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk-...',
                  labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentGreen)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What this key is for',
                  labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentGreen)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: textColor.withValues(alpha: 0.6)))),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final key = keyController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || key.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and key are required'), backgroundColor: Colors.red),
                  );
                  return;
                }

                Navigator.pop(context);
                _createApiKey(name, key, description: description.isEmpty ? null : description);
              },
              style: FilledButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.black),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
