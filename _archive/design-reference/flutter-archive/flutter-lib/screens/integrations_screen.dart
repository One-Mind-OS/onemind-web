import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'nats_control_screen.dart';
import 'api_keys_screen.dart';
import '../config/tactical_theme.dart';

/// Integrations Screen - External Service Connections
/// Manage OAuth connections and API integrations
/// Solar Punk Tactical Theme
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  List<Map<String, dynamic>> _integrations = [];
  bool _isLoading = true;
  String? _error;
  int _connectedCount = 0;
  int _totalCount = 0;
  String _selectedCategory = 'all'; // Removed final

  // Category to icon/color mapping
  final Map<String, Map<String, dynamic>> _categoryConfig = {
    'productivity': {'icon': Icons.work, 'color': const Color(0xFF4285F4)},
    'development': {'icon': Icons.code, 'color': const Color(0xFF8B5CF6)},
    'communication': {'icon': Icons.chat, 'color': const Color(0xFFF97316)},
    'smart_home': {'icon': Icons.home, 'color': const Color(0xFF06B6D4)},
    'cloud': {'icon': Icons.cloud_queue, 'color': const Color(0xFFFF9900)},
    'storage': {'icon': Icons.cloud, 'color': const Color(0xFF0061FF)},
    'finance': {'icon': Icons.payment, 'color': const Color(0xFF635BFF)},
    'media': {'icon': Icons.music_note, 'color': const Color(0xFF1DB954)},
  };

  // Integration name to icon mapping
  final Map<String, IconData> _integrationIcons = {
    'google_calendar': Icons.calendar_today,
    'github': Icons.code,
    'home_assistant': Icons.home,
    'notion': Icons.note,
    'slack': Icons.chat,
    'discord': Icons.discord,
    'clickup': Icons.task,
    'linear': Icons.linear_scale,
    'jira': Icons.bug_report,
    'gmail': Icons.email,
    'dropbox': Icons.cloud,
    'aws': Icons.cloud_queue,
    'stripe': Icons.payment,
    'twilio': Icons.phone,
    'spotify': Icons.music_note,
  };

  @override
  void initState() {
    super.initState();
    _loadIntegrations();
  }

  Future<void> _loadIntegrations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getIntegrationsStatus();

      setState(() {
        _integrations = (response['integrations'] as List<dynamic>)
            .map((i) => i as Map<String, dynamic>)
            .toList();
        _connectedCount = response['connected'] as int? ?? 0;
        _totalCount = response['total'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshIntegrations() async {
    try {
      await ApiService.refreshIntegrationsStatus();
      await _loadIntegrations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Integration status refreshed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _connected =>
      _integrations.where((i) => i['status'] == 'connected').toList();

  List<Map<String, dynamic>> get _available =>
      _integrations.where((i) => i['status'] != 'connected').toList();

  Color _getIntegrationColor(Map<String, dynamic> integration) {
    final category = integration['category'] as String?;
    if (category != null && _categoryConfig.containsKey(category)) {
      return _categoryConfig[category]!['color'] as Color;
    }
    return const Color(0xFF6B8F6B);
  }

  IconData _getIntegrationIcon(Map<String, dynamic> integration) {
    final name = (integration['name'] as String).toLowerCase().replaceAll(' ', '_');
    if (_integrationIcons.containsKey(name)) {
      return _integrationIcons[name]!;
    }
    return Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'INTEGRATIONS HUB',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: TacticalColors.primary,
            labelColor: TacticalColors.primary,
            unselectedLabelColor: TacticalColors.primary.withValues(alpha: 0.4),
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'CONNECTORS'),
              Tab(text: 'API KEYS'),
              Tab(text: 'NATS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConnectorsTab(),
            const ApiKeysScreen(embedded: true),
            const NatsControlScreen(embedded: true),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorsTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentGreen),
            const SizedBox(height: 16),
            Text('Loading integrations...', style: TextStyle(color: textColor)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error loading integrations', style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_error!, style: TextStyle(color: mutedText), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadIntegrations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accentBlue, const Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: accentBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.link, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Integrations', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Connect external services', style: TextStyle(color: mutedText, fontSize: 12)),
                      ],
                    ),
                  ),
                  _statChip('$_connectedCount', 'Connected', accentGreen),
                  const SizedBox(width: 8),
                  _statChip('${_totalCount - _connectedCount}', 'Available', accentOrange),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.refresh, color: accentBlue),
                    onPressed: _refreshIntegrations,
                    tooltip: 'Refresh status',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip('All', 'all', accentGreen),
                    _categoryChip('Productivity', 'productivity', accentBlue),
                    _categoryChip('Development', 'development', const Color(0xFF8B5CF6)),
                    _categoryChip('Communication', 'communication', accentOrange),
                    _categoryChip('Smart Home', 'smart_home', const Color(0xFF06B6D4)),
                    _categoryChip('Cloud', 'cloud', const Color(0xFFF97316)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadIntegrations,
            color: accentGreen,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_connected.isNotEmpty) ...[
                  _sectionHeader('Connected', accentGreen),
                  const SizedBox(height: 12),
                  ...(_selectedCategory == 'all' ? _connected : _connected.where((c) => c['category'] == _selectedCategory))
                      .map((i) => _integrationCard(i, true, cardBg, borderColor, accentGreen, textColor, mutedText)),
                  const SizedBox(height: 20),
                ],
                _sectionHeader('Available Integrations', accentBlue),
                const SizedBox(height: 12),
                if (_available.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'All integrations are connected!',
                      style: TextStyle(color: mutedText),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...(_selectedCategory == 'all' ? _available : _available.where((c) => c['category'] == _selectedCategory))
                      .map((i) => _integrationCard(i, false, cardBg, borderColor, accentGreen, textColor, mutedText)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _integrationCard(Map<String, dynamic> integration, bool connected, Color cardBg,
      Color borderColor, Color accentGreen, Color textColor, Color mutedText) {
    final color = _getIntegrationColor(integration);
    final icon = _getIntegrationIcon(integration);
    final name = integration['name'] as String;
    final category = integration['category'] as String;
    final health = integration['health'] as String?;
    final lastSync = integration['last_sync'] as String?;

    // Parse last sync time if available
    DateTime? lastSyncTime;
    if (lastSync != null) {
      try {
        lastSyncTime = DateTime.parse(lastSync);
      } catch (e) {
        // Ignore parse errors
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: connected ? accentGreen.withValues(alpha: 0.3) : borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            // Show integration details dialog
            _showIntegrationDetails(integration);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
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
                          Expanded(
                            child: Text(name, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                          if (health != null)
                            _healthBadge(health, accentGreen),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.replaceAll('_', ' '),
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                      if (connected && lastSyncTime != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.sync, size: 12, color: accentGreen),
                            const SizedBox(width: 4),
                            Text('Synced ${_formatTime(lastSyncTime)}', style: TextStyle(color: accentGreen, fontSize: 10)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (connected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Connected', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: mutedText.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Available', style: TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _healthBadge(String health, Color accentGreen) {
    Color badgeColor;
    IconData badgeIcon;

    switch (health) {
      case 'healthy':
        badgeColor = accentGreen;
        badgeIcon = Icons.check_circle;
        break;
      case 'degraded':
        badgeColor = Colors.orange;
        badgeIcon = Icons.warning;
        break;
      case 'unhealthy':
        badgeColor = Colors.red;
        badgeIcon = Icons.error;
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 10, color: badgeColor),
          const SizedBox(width: 4),
          Text(health, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
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

  void _showIntegrationDetails(Map<String, dynamic> integration) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    final details = integration['details'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(integration['name'] as String, style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${integration['status']}', style: TextStyle(color: textColor)),
            Text('Health: ${integration['health']}', style: TextStyle(color: textColor)),
            Text('Category: ${integration['category']}', style: TextStyle(color: textColor)),
            if (integration['last_sync'] != null)
              Text('Last Sync: ${integration['last_sync']}', style: TextStyle(color: textColor)),
            const SizedBox(height: 16),
            if (details != null) ...[
              Text('Details:', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...details.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${e.key}: ${e.value}', style: TextStyle(color: mutedText, fontSize: 12)),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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

  Widget _categoryChip(String label, String value, Color color) {
    final isSelected = _selectedCategory == value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        backgroundColor: color.withValues(alpha: 0.1),
        selectedColor: color.withValues(alpha: 0.3),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? color : Colors.transparent),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
