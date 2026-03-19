import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// Unified Asset Browser - Shows all asset types in one place
/// Tabs: All | Humans | Machines | Devices | Locations
class AssetsBrowserScreen extends ConsumerStatefulWidget {
  const AssetsBrowserScreen({super.key});

  @override
  ConsumerState<AssetsBrowserScreen> createState() => _AssetsBrowserScreenState();
}

class _AssetsBrowserScreenState extends ConsumerState<AssetsBrowserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _assets = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Asset type filter
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAssets();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Map tab index to asset type filter
      switch (_tabController.index) {
        case 0:
          _currentFilter = null; // All
          break;
        case 1:
          _currentFilter = 'human';
          break;
        case 2:
          _currentFilter = 'machine';
          break;
        case 3:
          _currentFilter = 'device';
          break;
        case 4:
          _currentFilter = 'location';
          break;
      }
      _loadAssets();
    }
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assets = await ApiService.listAssets(
        assetType: _currentFilter,
        limit: 500,
      );
      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAssets {
    if (_searchQuery.isEmpty) return _assets;

    final query = _searchQuery.toLowerCase();
    return _assets.where((asset) {
      final name = (asset['name'] ?? '').toString().toLowerCase();
      final type = (asset['asset_type'] ?? '').toString().toLowerCase();
      final subType = (asset['sub_type'] ?? '').toString().toLowerCase();
      return name.contains(query) || type.contains(query) || subType.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('All Assets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search assets...',
                    prefixIcon: Icon(Icons.search, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Humans'),
                  Tab(text: 'Machines'),
                  Tab(text: 'Devices'),
                  Tab(text: 'Locations'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _filteredAssets.isEmpty
                  ? _buildEmptyView()
                  : _buildAssetsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create asset screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Asset - Coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Asset'),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading assets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAssets,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No assets found' : 'No assets yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Create your first asset to get started',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    return RefreshIndicator(
      onRefresh: _loadAssets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAssets.length,
        itemBuilder: (context, index) {
          final asset = _filteredAssets[index];
          return _buildAssetCard(asset);
        },
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final theme = Theme.of(context);

    final name = asset['name'] ?? 'Unnamed Asset';
    final type = asset['asset_type'] ?? 'unknown';
    final subType = asset['sub_type'] ?? '';
    final status = asset['status'] ?? 'unknown';
    final location = asset['location'] ?? '';
    final latitude = asset['latitude'];
    final longitude = asset['longitude'];

    // Get icon based on type
    IconData icon;
    Color iconColor;
    switch (type.toLowerCase()) {
      case 'human':
        icon = Icons.person_outline;
        iconColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'machine':
        icon = Icons.precision_manufacturing_outlined;
        iconColor = const Color(0xFFF97316); // Orange
        break;
      case 'device':
        icon = Icons.devices_outlined;
        iconColor = const Color(0xFF8B5CF6); // Purple
        break;
      case 'location':
        icon = Icons.location_on_outlined;
        iconColor = const Color(0xFF10B981); // Green
        break;
      default:
        icon = Icons.category_outlined;
        iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }

    // Status indicator color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
        statusColor = const Color(0xFF10B981);
        break;
      case 'offline':
      case 'inactive':
        statusColor = const Color(0xFF6B7280);
        break;
      case 'error':
      case 'critical':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'warning':
        statusColor = const Color(0xFFF59E0B);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to asset detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Asset Detail: $name - Coming soon!')),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Status indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Type + SubType
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: iconColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (subType.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            subType,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location/Coordinates
                    if (latitude != null && longitude != null)
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      )
                    else if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_city_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Action button
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: () {
                  // TODO: Navigate to asset detail
                },
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
