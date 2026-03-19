import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';

/// Base class for list/CRUD screens with common patterns
///
/// Provides:
/// - Search functionality
/// - Delete confirmation dialogs
/// - Loading/error state handling
/// - Standard AppBar and search bar UI
/// - SnackBar helpers for success/error messages
///
/// Usage:
/// ```dart
/// class AgentsScreen extends BaseListScreen<AgentModel> {
///   const AgentsScreen({super.key}) : super(
///     title: 'AGENT MANAGEMENT',
///     entityNameSingular: 'Agent',
///     entityNamePlural: 'Agents',
///   );
///
///   @override
///   AsyncValue<List<AgentModel>> watchItems(WidgetRef ref) => ref.watch(agentsProvider);
///
///   @override
///   Widget buildItemCard(AgentModel item) { ... }
///
///   @override
///   bool matchesSearch(AgentModel item, String query) { ... }
/// }
/// ```
abstract class BaseListScreen<T> extends ConsumerStatefulWidget {
  final String title;
  final String entityNameSingular;
  final String entityNamePlural;
  final bool showCreateButton;
  final bool showRefreshButton;
  final Widget? customHeaderWidget;

  const BaseListScreen({
    super.key,
    required this.title,
    required this.entityNameSingular,
    required this.entityNamePlural,
    this.showCreateButton = true,
    this.showRefreshButton = false,
    this.customHeaderWidget,
  });

  @override
  BaseListScreenState<T> createState();
}

abstract class BaseListScreenState<T> extends ConsumerState<BaseListScreen<T>> {
  String _searchQuery = '';
  bool _isLoading = false;

  // ============================================================================
  // Abstract methods - Subclasses must implement
  // ============================================================================

  /// Watch the provider for list data
  AsyncValue<List<T>> watchItems(WidgetRef ref);

  /// Build the card widget for a single item
  Widget buildItemCard(BuildContext context, T item);

  /// Check if item matches search query
  bool matchesSearch(T item, String query);

  // ============================================================================
  // Optional overrides - Subclasses can customize
  // ============================================================================

  /// Get item ID for deletion/navigation
  String getItemId(T item) => '';

  /// Get item name for display
  String getItemName(T item) => widget.entityNameSingular;

  /// Custom filtering logic (in addition to search)
  List<T> applyCustomFilters(List<T> items) => items;

  /// Custom sorting logic
  List<T> applySorting(List<T> items) => items;

  /// Delete an item (return true on success)
  Future<bool> deleteItem(String itemId) async => false;

  /// Refresh/reload items
  Future<void> refreshItems() async {}

  /// Navigate to create form
  void navigateToCreate() {}

  /// Navigate to edit form
  void navigateToEdit(T item) {}

  /// Build custom actions for the item card
  List<Widget> buildItemActions(T item) => [];

  /// Build custom header widgets (e.g., filters, stats)
  Widget? buildCustomHeader() => widget.customHeaderWidget;

  /// Empty state message
  String getEmptyStateMessage() => 'No ${widget.entityNamePlural.toLowerCase()} found';

  /// Empty state icon
  IconData getEmptyStateIcon() => Icons.inbox_outlined;

  // ============================================================================
  // Common functionality
  // ============================================================================

  List<T> _filterAndSortItems(List<T> items) {
    var filtered = items;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => matchesSearch(item, _searchQuery.toLowerCase())).toList();
    }

    // Apply custom filters
    filtered = applyCustomFilters(filtered);

    // Apply sorting
    filtered = applySorting(filtered);

    return filtered;
  }

  Future<void> handleDelete(T item) async {
    final itemId = getItemId(item);
    final itemName = getItemName(item);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete ${widget.entityNameSingular}',
          style: TextStyle(
            color: TacticalColors.primary,
            fontFamily: 'monospace',
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$itemName"?',
          style: TextStyle(
            color: TacticalColors.primary.withValues(alpha: 0.7),
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await deleteItem(itemId);
        if (success && mounted) {
          showSuccessMessage('${widget.entityNameSingular} "$itemName" deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          showErrorMessage('Failed to delete ${widget.entityNameSingular.toLowerCase()}: $e');
        }
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    try {
      await refreshItems();
      if (mounted) {
        showSuccessMessage('${widget.entityNamePlural} refreshed successfully');
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage('Failed to refresh: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TacticalColors.primary,
      ),
    );
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================================
  // UI Builders
  // ============================================================================

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TacticalColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        style: TextStyle(
          color: TacticalColors.primary,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: 'Search ${widget.entityNamePlural.toLowerCase()}...',
          hintStyle: TextStyle(
            color: TacticalColors.primary.withValues(alpha: 0.5),
            fontFamily: 'monospace',
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: TacticalColors.primary.withValues(alpha: 0.5),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(
          bottom: BorderSide(
            color: TacticalColors.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchBar()),
              if (widget.showRefreshButton) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isLoading ? null : _handleRefresh,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TacticalColors.primary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  color: TacticalColors.primary,
                  tooltip: 'Refresh',
                ),
              ],
              if (widget.showCreateButton) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: navigateToCreate,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('CREATE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TacticalColors.accent,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (buildCustomHeader() != null) ...[
            const SizedBox(height: 12),
            buildCustomHeader()!,
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TacticalColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: TacticalColors.primary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading ${widget.entityNamePlural.toLowerCase()}',
            style: TextStyle(
              color: TacticalColors.primary,
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: TacticalColors.primary.withValues(alpha: 0.7),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('RETRY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getEmptyStateIcon(),
            size: 64,
            color: TacticalColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            getEmptyStateMessage(),
            style: TextStyle(
              color: TacticalColors.primary,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<T> items) {
    final filtered = _filterAndSortItems(items);

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return buildListWidget(filtered);
  }

  /// Build the list/grid widget - can be overridden for custom layouts
  Widget buildListWidget(List<T> filteredItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return buildItemCard(context, filteredItems[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = watchItems(ref);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeaderBar(),
          Expanded(
            child: itemsAsync.when(
              data: (items) => _buildListView(items),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }
}
