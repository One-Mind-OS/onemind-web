// Query Editor Widget (OMOS-241)
// SQL/command query interface with results display for database exploration

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/services/api_client.dart';
import '../../../shared/theme/tactical.dart';

/// Query result from database
class QueryResult {
  final bool success;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final int rowCount;
  final double executionTimeMs;
  final String? error;
  final String? warning;

  const QueryResult({
    required this.success,
    this.columns = const [],
    this.rows = const [],
    this.rowCount = 0,
    this.executionTimeMs = 0,
    this.error,
    this.warning,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) {
    return QueryResult(
      success: json['success'] as bool? ?? false,
      columns: List<String>.from(json['columns'] ?? []),
      rows: (json['rows'] as List<dynamic>?)
              ?.map((r) => List<dynamic>.from(r as List))
              .toList() ??
          [],
      rowCount: json['row_count'] as int? ?? 0,
      executionTimeMs: (json['execution_time_ms'] as num?)?.toDouble() ?? 0,
      error: json['error'] as String?,
      warning: json['warning'] as String?,
    );
  }
}

/// Query editor widget for executing database queries
class QueryEditor extends ConsumerStatefulWidget {
  final String databaseType; // postgres, redis, timescale, nats
  final String databaseName;

  const QueryEditor({
    super.key,
    required this.databaseType,
    required this.databaseName,
  });

  @override
  ConsumerState<QueryEditor> createState() => _QueryEditorState();
}

class _QueryEditorState extends ConsumerState<QueryEditor> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  bool _isExecuting = false;
  QueryResult? _result;
  final List<String> _history = [];
  int _historyIndex = -1;

  // Example queries per database type
  static const Map<String, List<String>> _exampleQueries = {
    'postgres': [
      'SELECT * FROM ai.user_memories LIMIT 10',
      'SELECT table_name FROM information_schema.tables WHERE table_schema = \'ai\'',
      'SELECT COUNT(*) FROM ai.sessions',
    ],
    'redis': [
      'KEYS awareness:*',
      'GET awareness:state',
      'INFO',
      'DBSIZE',
    ],
    'timescale': [
      'SELECT * FROM events.nats_messages LIMIT 10',
      'SELECT COUNT(*) FROM events.agent_runs',
      'SELECT time_bucket(\'1 hour\', time) AS bucket, COUNT(*) FROM events.nats_messages GROUP BY bucket ORDER BY bucket DESC LIMIT 24',
    ],
    'nats': [
      'STREAM info EVENTS',
      'STREAM list',
      'CONSUMER list EVENTS',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Set initial example query
    final examples = _exampleQueries[widget.databaseType] ?? [];
    if (examples.isNotEmpty) {
      _queryController.text = examples.first;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _executeQuery() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isExecuting = true;
      _result = null;
    });

    // Add to history
    if (_history.isEmpty || _history.last != query) {
      _history.add(query);
      _historyIndex = _history.length;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/api/databases/query', {
        'database': widget.databaseType,
        'query': query,
        'limit': 100,
        'read_only': true,
      });

      setState(() {
        _isExecuting = false;
        _result = QueryResult.fromJson(response);
      });
    } catch (e) {
      setState(() {
        _isExecuting = false;
        _result = QueryResult(
          success: false,
          error: e.toString(),
        );
      });
    }
  }

  void _navigateHistory(int delta) {
    if (_history.isEmpty) return;
    final newIndex = (_historyIndex + delta).clamp(0, _history.length - 1);
    if (newIndex != _historyIndex) {
      setState(() {
        _historyIndex = newIndex;
        _queryController.text = _history[newIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OSDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(color: TacticalColors.border, height: 1),
          _buildQueryInput(),
          const Divider(color: TacticalColors.border, height: 1),
          _buildToolbar(),
          if (_result != null) ...[
            const Divider(color: TacticalColors.border, height: 1),
            _buildResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: TacticalColors.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          Text('QUERY', style: OSTypography.sectionHeader),
          const Spacer(),
          // Database type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: OSDecoration.statusBadge(_getDatabaseColor()),
            child: Text(
              widget.databaseName.toUpperCase(),
              style: OSTypography.status(_getDatabaseColor()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryInput() {
    final isSQL =
        widget.databaseType == 'postgres' || widget.databaseType == 'timescale';

    return Container(
      padding: const EdgeInsets.all(16),
      color: TacticalColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint text
          Text(
            isSQL ? 'SELECT queries only (read-only mode)' : 'Read commands only',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          // Query input
          RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) {
              if (event is RawKeyDownEvent) {
                // Ctrl/Cmd + Enter to execute
                if ((event.isControlPressed || event.isMetaPressed) &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _executeQuery();
                }
                // Up arrow for history
                if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
                    event.isAltPressed) {
                  _navigateHistory(-1);
                }
                // Down arrow for history
                if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                    event.isAltPressed) {
                  _navigateHistory(1);
                }
              }
            },
            child: TextField(
              controller: _queryController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: isSQL
                    ? 'SELECT * FROM table_name LIMIT 10'
                    : 'KEYS pattern:*',
                hintStyle: TextStyle(
                  color: TacticalColors.textDim,
                  fontFamily: 'monospace',
                ),
                filled: true,
                fillColor: TacticalColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TacticalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TacticalColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TacticalColors.primary),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Example queries
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_exampleQueries[widget.databaseType] ?? [])
                .take(3)
                .map((example) => InkWell(
                      onTap: () => _queryController.text = example,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TacticalColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          example.length > 40
                              ? '${example.substring(0, 40)}...'
                              : example,
                          style: const TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // History dropdown
          if (_history.isNotEmpty)
            PopupMenuButton<int>(
              tooltip: 'Query history',
              icon: const Icon(
                Icons.history,
                size: 18,
                color: TacticalColors.textMuted,
              ),
              color: TacticalColors.card,
              itemBuilder: (context) => _history
                  .asMap()
                  .entries
                  .map((e) => PopupMenuItem(
                        value: e.key,
                        child: Text(
                          e.value.length > 50
                              ? '${e.value.substring(0, 50)}...'
                              : e.value,
                          style: OSTypography.code,
                        ),
                      ))
                  .toList()
                  .reversed
                  .toList(),
              onSelected: (index) {
                setState(() {
                  _historyIndex = index;
                  _queryController.text = _history[index];
                });
              },
            ),
          const Spacer(),
          // Result stats
          if (_result != null && _result!.success) ...[
            Text(
              '${_result!.executionTimeMs.toStringAsFixed(0)}ms',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_result!.rowCount} rows',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 16),
          ],
          // Execute button
          ElevatedButton.icon(
            onPressed: _isExecuting ? null : _executeQuery,
            icon: _isExecuting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow, size: 16),
            label: Text(_isExecuting ? 'RUNNING...' : 'EXECUTE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_result == null) return const SizedBox.shrink();

    // Error state
    if (!_result!.success || _result!.error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: TacticalColors.error.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 20,
              color: TacticalColors.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ERROR',
                    style: OSTypography.status(TacticalColors.error),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _result!.error ?? 'Unknown error',
                    style: const TextStyle(
                      color: TacticalColors.error,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Warning
    Widget? warningWidget;
    if (_result!.warning != null) {
      warningWidget = Container(
        padding: const EdgeInsets.all(12),
        color: TacticalColors.warning.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              size: 16,
              color: TacticalColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _result!.warning!,
                style: TextStyle(
                  color: TacticalColors.warning,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty result
    if (_result!.rows.isEmpty) {
      return Column(
        children: [
          if (warningWidget != null) warningWidget,
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inbox,
                  size: 32,
                  color: TacticalColors.textDim,
                ),
                const SizedBox(height: 8),
                Text(
                  'No results',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Results table
    return Column(
      children: [
        if (warningWidget != null) warningWidget,
        // Results header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: TacticalColors.surface,
          child: Row(
            children: [
              Text('RESULTS', style: OSTypography.label),
              const Spacer(),
              // Copy results button
              IconButton(
                icon: const Icon(Icons.copy, size: 14),
                onPressed: _copyResults,
                tooltip: 'Copy as JSON',
                color: TacticalColors.textMuted,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ],
          ),
        ),
        // Data table
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.depth == 1,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      TacticalColors.surface,
                    ),
                    dataRowColor: WidgetStateProperty.all(
                      TacticalColors.card,
                    ),
                    headingRowHeight: 40,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 48,
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    columns: _result!.columns
                        .map((col) => DataColumn(
                              label: Text(
                                col.toUpperCase(),
                                style: OSTypography.label,
                              ),
                            ))
                        .toList(),
                    rows: _result!.rows
                        .take(100)
                        .map((row) => DataRow(
                              cells: row
                                  .map((cell) => DataCell(
                                        SelectableText(
                                          _formatCell(cell),
                                          style: OSTypography.code,
                                        ),
                                      ))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Footer with row count
        if (_result!.rowCount > 100)
          Container(
            padding: const EdgeInsets.all(12),
            color: TacticalColors.surface,
            child: Text(
              'Showing 100 of ${_result!.rowCount} rows',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  String _formatCell(dynamic value) {
    if (value == null) return 'NULL';
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    final str = value.toString();
    // Truncate long strings
    if (str.length > 100) {
      return '${str.substring(0, 100)}...';
    }
    return str;
  }

  void _copyResults() {
    if (_result == null || !_result!.success) return;

    final data = {
      'columns': _result!.columns,
      'rows': _result!.rows,
      'row_count': _result!.rowCount,
    };

    Clipboard.setData(ClipboardData(
      text: const JsonEncoder.withIndent('  ').convert(data),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results copied to clipboard')),
    );
  }

  Color _getDatabaseColor() {
    switch (widget.databaseType) {
      case 'postgres':
        return const Color(0xFF336791);
      case 'redis':
        return const Color(0xFFDC382D);
      case 'timescale':
        return const Color(0xFFFDB515);
      case 'nats':
        return const Color(0xFF27AAE1);
      default:
        return TacticalColors.primary;
    }
  }
}
