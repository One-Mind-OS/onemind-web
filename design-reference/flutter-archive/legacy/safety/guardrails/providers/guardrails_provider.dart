// Guardrails provider using Riverpod
// OMOS-251: Guardrails moderation config

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/providers/app_providers.dart';

/// Guardrails configuration model
class GuardrailsConfig {
  final bool moderationEnabled;
  final bool inputValidation;
  final bool outputValidation;
  final bool piiFilter;
  final bool profanityFilter;
  final double toxicityThreshold;
  final List<String> blockedCategories;
  final String model;
  final DateTime? updatedAt;

  const GuardrailsConfig({
    this.moderationEnabled = true,
    this.inputValidation = true,
    this.outputValidation = true,
    this.piiFilter = true,
    this.profanityFilter = false,
    this.toxicityThreshold = 0.7,
    this.blockedCategories = const [],
    this.model = 'text-moderation-stable',
    this.updatedAt,
  });

  GuardrailsConfig copyWith({
    bool? moderationEnabled,
    bool? inputValidation,
    bool? outputValidation,
    bool? piiFilter,
    bool? profanityFilter,
    double? toxicityThreshold,
    List<String>? blockedCategories,
    String? model,
    DateTime? updatedAt,
  }) {
    return GuardrailsConfig(
      moderationEnabled: moderationEnabled ?? this.moderationEnabled,
      inputValidation: inputValidation ?? this.inputValidation,
      outputValidation: outputValidation ?? this.outputValidation,
      piiFilter: piiFilter ?? this.piiFilter,
      profanityFilter: profanityFilter ?? this.profanityFilter,
      toxicityThreshold: toxicityThreshold ?? this.toxicityThreshold,
      blockedCategories: blockedCategories ?? this.blockedCategories,
      model: model ?? this.model,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GuardrailsConfig.fromJson(Map<String, dynamic> json) {
    return GuardrailsConfig(
      moderationEnabled: json['moderation_enabled'] as bool? ?? true,
      inputValidation: json['input_validation'] as bool? ?? true,
      outputValidation: json['output_validation'] as bool? ?? true,
      piiFilter: json['pii_filter'] as bool? ?? true,
      profanityFilter: json['profanity_filter'] as bool? ?? false,
      toxicityThreshold: (json['toxicity_threshold'] as num?)?.toDouble() ?? 0.7,
      blockedCategories: (json['blocked_categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      model: json['model'] as String? ?? 'text-moderation-stable',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Count of active protections
  int get activeProtections {
    int count = 0;
    if (moderationEnabled) count++;
    if (inputValidation) count++;
    if (outputValidation) count++;
    if (piiFilter) count++;
    if (profanityFilter) count++;
    return count;
  }
}

/// Guardrails violation model
class GuardrailsViolation {
  final String id;
  final String type; // blocked, filtered, warning
  final String severity; // high, medium, low
  final String message;
  final String? category;
  final String? inputSnippet;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  const GuardrailsViolation({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.category,
    this.inputSnippet,
    this.details = const {},
    required this.createdAt,
  });

  factory GuardrailsViolation.fromJson(Map<String, dynamic> json) {
    return GuardrailsViolation(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      severity: json['severity'] as String? ?? 'medium',
      message: json['message'] as String? ?? '',
      category: json['category'] as String?,
      inputSnippet: json['input_snippet'] as String?,
      details: json['details'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Guardrails state
class GuardrailsState {
  final GuardrailsConfig config;
  final List<GuardrailsViolation> violations;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const GuardrailsState({
    this.config = const GuardrailsConfig(),
    this.violations = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  GuardrailsState copyWith({
    GuardrailsConfig? config,
    List<GuardrailsViolation>? violations,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return GuardrailsState(
      config: config ?? this.config,
      violations: violations ?? this.violations,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  int get violationsToday {
    final today = DateTime.now();
    return violations.where((v) {
      return v.createdAt.year == today.year &&
          v.createdAt.month == today.month &&
          v.createdAt.day == today.day;
    }).length;
  }
}

/// Guardrails notifier with API integration
class GuardrailsNotifier extends StateNotifier<GuardrailsState> {
  final Ref _ref;

  GuardrailsNotifier(this._ref) : super(const GuardrailsState()) {
    _loadConfig();
    _loadViolations();
  }

  Future<void> _loadConfig() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = _ref.read(agnoClientProvider);
      final data = await client.getGuardrailsConfig();

      if (data != null) {
        state = state.copyWith(
          config: GuardrailsConfig.fromJson(data),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadViolations() async {
    try {
      final client = _ref.read(agnoClientProvider);
      final data = await client.getGuardrailsViolations();

      state = state.copyWith(
        violations: data.map((v) => GuardrailsViolation.fromJson(v)).toList(),
      );
    } catch (e) {
      // Don't set error for violations load failure
    }
  }

  /// Refresh config and violations
  Future<void> refresh() async {
    await _loadConfig();
    await _loadViolations();
  }

  /// Update a single config field
  Future<void> updateConfig({
    bool? moderationEnabled,
    bool? inputValidation,
    bool? outputValidation,
    bool? piiFilter,
    bool? profanityFilter,
    double? toxicityThreshold,
    List<String>? blockedCategories,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final client = _ref.read(agnoClientProvider);

      // Optimistic update
      state = state.copyWith(
        config: state.config.copyWith(
          moderationEnabled: moderationEnabled,
          inputValidation: inputValidation,
          outputValidation: outputValidation,
          piiFilter: piiFilter,
          profanityFilter: profanityFilter,
          toxicityThreshold: toxicityThreshold,
          blockedCategories: blockedCategories,
        ),
      );

      // Call API
      final result = await client.updateGuardrailsConfig(
        moderationEnabled: moderationEnabled,
        inputValidation: inputValidation,
        outputValidation: outputValidation,
        piiFilter: piiFilter,
        profanityFilter: profanityFilter,
        toxicityThreshold: toxicityThreshold,
        blockedCategories: blockedCategories,
      );

      if (result != null) {
        state = state.copyWith(
          config: GuardrailsConfig.fromJson(result),
          isSaving: false,
        );
      } else {
        state = state.copyWith(isSaving: false);
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle moderation enabled
  Future<void> toggleModeration() async {
    await updateConfig(moderationEnabled: !state.config.moderationEnabled);
  }

  /// Toggle input validation
  Future<void> toggleInputValidation() async {
    await updateConfig(inputValidation: !state.config.inputValidation);
  }

  /// Toggle output validation
  Future<void> toggleOutputValidation() async {
    await updateConfig(outputValidation: !state.config.outputValidation);
  }

  /// Toggle PII filter
  Future<void> togglePiiFilter() async {
    await updateConfig(piiFilter: !state.config.piiFilter);
  }

  /// Toggle profanity filter
  Future<void> toggleProfanityFilter() async {
    await updateConfig(profanityFilter: !state.config.profanityFilter);
  }

  /// Set toxicity threshold
  Future<void> setToxicityThreshold(double value) async {
    await updateConfig(toxicityThreshold: value);
  }

  /// Clear all violations
  Future<void> clearViolations() async {
    try {
      final client = _ref.read(agnoClientProvider);
      final success = await client.clearGuardrailsViolations();

      if (success) {
        state = state.copyWith(violations: []);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for guardrails state
final guardrailsProvider =
    StateNotifierProvider<GuardrailsNotifier, GuardrailsState>((ref) {
  return GuardrailsNotifier(ref);
});

/// Provider for active protections count
final activeProtectionsProvider = Provider<int>((ref) {
  return ref.watch(guardrailsProvider).config.activeProtections;
});

/// Provider for today's violation count
final violationsTodayProvider = Provider<int>((ref) {
  return ref.watch(guardrailsProvider).violationsToday;
});

/// Provider for recent violations (last 5)
final recentViolationsProvider = Provider<List<GuardrailsViolation>>((ref) {
  return ref.watch(guardrailsProvider).violations.take(5).toList();
});
