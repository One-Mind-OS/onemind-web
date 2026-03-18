import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// Capabilities Screen - Skills & Capabilities Registry
/// Shows all system capabilities: digital, physical, hybrid
/// Solar Punk Tactical Theme
class CapabilitiesScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const CapabilitiesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CapabilitiesScreen> createState() => _CapabilitiesScreenState();
}

class _CapabilitiesScreenState extends ConsumerState<CapabilitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedDomain = 'all';
  String _selectedHandler = 'all';

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _capabilities = [];

  // Stats from API
  int _digitalCount = 0;
  int _physicalCount = 0;
  int _hybridCount = 0;
  int _systemCount = 0;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCapabilities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCapabilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch capabilities from backend
      final response = await ApiService.getCapabilities();
      final caps = response['capabilities'] as List<dynamic>;

      setState(() {
        // Convert backend format to frontend format
        _capabilities = caps.map((cap) {
          final capMap = cap as Map<String, dynamic>;
          // Backend has handler_type and handler_id separate
          // Frontend combines them as "type:id"
          final handler = '${capMap['handler_type']}:${capMap['handler_id']}';

          return {
            'name': capMap['name'],
            'description': capMap['description'],
            'handler': handler,
            'domain': capMap['domain'],
            'approval': capMap['approval'],
            'category': capMap['category'],
            'keywords': capMap['keywords'] ?? [],
            'enabled': capMap['enabled'] ?? true,
          };
        }).toList();

        // Calculate stats
        _digitalCount = _capabilities.where((c) => c['domain'] == 'digital').length;
        _physicalCount = _capabilities.where((c) => c['domain'] == 'physical').length;
        _hybridCount = _capabilities.where((c) => c['domain'] == 'hybrid').length;
        _systemCount = _capabilities.where((c) => c['domain'] == 'system').length;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCapabilities {
    return _capabilities.where((cap) {
      final matchesDomain = _selectedDomain == 'all' || cap['domain'] == _selectedDomain;
      final matchesHandler = _selectedHandler == 'all' || (cap['handler'] as String).startsWith(_selectedHandler);
      final matchesSearch = _searchQuery.isEmpty ||
          (cap['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (cap['description'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (cap['keywords'] as List).any((k) => k.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesDomain && matchesHandler && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Solar Punk colors
    final bg = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF5F7F5);
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);
    final accentPurple = const Color(0xFF8B5CF6);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    // Use cached stats from _loadCapabilities()
    final digitalCount = _digitalCount;
    final physicalCount = _physicalCount;
    final hybridCount = _hybridCount;
    final systemCount = _systemCount;

    final mainContent = _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: accentGreen),
                const SizedBox(height: 16),
                Text('Loading capabilities...', style: TextStyle(color: mutedText)),
              ],
            ),
          )
        : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: accentOrange),
                    const SizedBox(height: 16),
                    Text('Error loading capabilities', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(_error!, style: TextStyle(color: mutedText, fontSize: 12)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadCapabilities,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
                    ),
                  ],
                ),
              )
            : Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentGreen, const Color(0xFF166534)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capabilities',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Skills & capabilities registry',
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Stats
                    _statChip('$digitalCount', 'Digital', accentGreen),
                    const SizedBox(width: 8),
                    _statChip('$physicalCount', 'Physical', accentOrange),
                    const SizedBox(width: 8),
                    _statChip('$hybridCount', 'Hybrid', accentPurple),
                    const SizedBox(width: 8),
                    _statChip('$systemCount', 'System', accentBlue),
                    const SizedBox(width: 12),
                    // Refresh button
                    IconButton(
                      icon: Icon(Icons.refresh, color: accentGreen, size: 20),
                      onPressed: _loadCapabilities,
                      tooltip: 'Refresh capabilities',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search & Filters
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: TextStyle(color: textColor, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search capabilities...',
                            hintStyle: TextStyle(color: mutedText),
                            prefixIcon: Icon(Icons.search, color: mutedText, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _filterDropdown('Domain', _selectedDomain, ['all', 'digital', 'physical', 'hybrid', 'system'], (v) => setState(() => _selectedDomain = v!), borderColor, textColor),
                    const SizedBox(width: 12),
                    _filterDropdown('Handler', _selectedHandler, ['all', 'agent', 'tool', 'team', 'bridge'], (v) => setState(() => _selectedHandler = v!), borderColor, textColor),
                  ],
                ),
                const SizedBox(height: 12),
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: accentGreen,
                  unselectedLabelColor: mutedText,
                  indicatorColor: accentGreen,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: 'All (${_capabilities.length})'),
                    Tab(text: 'Digital ($digitalCount)'),
                    Tab(text: 'Physical ($physicalCount)'),
                    Tab(text: 'Hybrid ($hybridCount)'),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCapabilityList('all', cardBg, borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
                _buildCapabilityList('digital', cardBg, borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
                _buildCapabilityList('physical', cardBg, borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
                _buildCapabilityList('hybrid', cardBg, borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
              ],
            ),
          ),
        ],
      );

    if (widget.embedded) return mainContent;

    return Scaffold(
      backgroundColor: bg,
      body: mainContent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCapabilityDialog,
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Capability', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _filterDropdown(String label, String value, List<String> options, Function(String?) onChanged, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: TextStyle(color: textColor, fontSize: 13),
        dropdownColor: const Color(0xFF0F1A0F),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o == 'all' ? 'All ${label}s' : o.capitalize()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCapabilityList(String domain, Color cardBg, Color borderColor,
      Color accentGreen, Color accentOrange, Color accentBlue, Color accentPurple,
      Color textColor, Color mutedText) {
    final caps = domain == 'all'
        ? _filteredCapabilities
        : _filteredCapabilities.where((c) => c['domain'] == domain).toList();

    if (caps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: mutedText.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No capabilities found', style: TextStyle(color: mutedText)),
          ],
        ),
      );
    }

    // Group by category
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final cap in caps) {
      final cat = cap['category'] as String;
      grouped.putIfAbsent(cat, () => []).add(cap);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final items = grouped[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...items.map((cap) => _capabilityCard(
                  cap,
                  cardBg,
                  borderColor,
                  _getDomainColor(cap['domain'] as String, accentGreen, accentOrange, accentBlue, accentPurple),
                  textColor,
                  mutedText,
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Color _getDomainColor(String domain, Color green, Color orange, Color blue, Color purple) {
    switch (domain) {
      case 'digital':
        return green;
      case 'physical':
        return orange;
      case 'hybrid':
        return purple;
      case 'system':
        return blue;
      default:
        return green;
    }
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'digital':
        return Icons.computer;
      case 'physical':
        return Icons.precision_manufacturing;
      case 'hybrid':
        return Icons.sync_alt;
      case 'system':
        return Icons.settings;
      default:
        return Icons.bolt;
    }
  }

  IconData _getHandlerIcon(String handler) {
    if (handler.startsWith('agent:')) return Icons.smart_toy;
    if (handler.startsWith('tool:')) return Icons.build;
    if (handler.startsWith('team:')) return Icons.groups;
    if (handler.startsWith('bridge:')) return Icons.hub;
    return Icons.extension;
  }

  Color _getApprovalColor(String approval, Color green, Color orange, Color red) {
    switch (approval) {
      case 'none':
        return green;
      case 'notify':
        return const Color(0xFF3B82F6);
      case 'confirm':
        return orange;
      case 'review':
        return red;
      default:
        return green;
    }
  }

  Widget _capabilityCard(Map<String, dynamic> cap, Color cardBg, Color borderColor,
      Color domainColor, Color textColor, Color mutedText) {
    final handler = cap['handler'] as String;
    final approval = cap['approval'] as String;
    final keywords = cap['keywords'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _showCapabilityDetail(cap),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Domain icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: domainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getDomainIcon(cap['domain'] as String), color: domainColor, size: 22),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            cap['name'] as String,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: domainColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cap['domain'] as String,
                              style: TextStyle(color: domainColor, fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cap['description'] as String,
                        style: TextStyle(color: mutedText, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Handler
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: borderColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getHandlerIcon(handler), size: 12, color: mutedText),
                                const SizedBox(width: 4),
                                Text(handler, style: TextStyle(color: textColor, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Approval
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getApprovalColor(approval, const Color(0xFF4ADE80), const Color(0xFFF97316), Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  approval == 'none' ? Icons.check_circle : approval == 'confirm' ? Icons.warning : Icons.info,
                                  size: 12,
                                  color: _getApprovalColor(approval, const Color(0xFF4ADE80), const Color(0xFFF97316), Colors.red),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  approval,
                                  style: TextStyle(
                                    color: _getApprovalColor(approval, const Color(0xFF4ADE80), const Color(0xFFF97316), Colors.red),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Keywords count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${keywords.length} keywords',
                    style: TextStyle(color: mutedText, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: mutedText, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCapabilityDetail(Map<String, dynamic> cap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);
    final accentGreen = const Color(0xFF4ADE80);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getDomainIcon(cap['domain'] as String), color: accentGreen, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cap['name'] as String, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(cap['description'] as String, style: TextStyle(color: mutedText, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: borderColor),
              const SizedBox(height: 16),
              _detailRow('Domain', cap['domain'] as String, Icons.category, textColor, mutedText),
              _detailRow('Handler', cap['handler'] as String, _getHandlerIcon(cap['handler'] as String), textColor, mutedText),
              _detailRow('Approval', cap['approval'] as String, Icons.verified_user, textColor, mutedText),
              _detailRow('Category', cap['category'] as String, Icons.folder, textColor, mutedText),
              const SizedBox(height: 16),
              Text('Keywords', style: TextStyle(color: accentGreen, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (cap['keywords'] as List).map((k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(k.toString(), style: TextStyle(color: accentGreen, fontSize: 11)),
                    )).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentGreen,
                        side: BorderSide(color: accentGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Test'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, IconData icon, Color textColor, Color mutedText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: mutedText),
          const SizedBox(width: 10),
          Text('$label: ', style: TextStyle(color: mutedText, fontSize: 12)),
          Text(value, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAddCapabilityDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final accentGreen = const Color(0xFF4ADE80);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Add Capability', style: TextStyle(color: textColor)),
        content: Text('Coming soon - add custom capabilities to the registry.', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: accentGreen)),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
