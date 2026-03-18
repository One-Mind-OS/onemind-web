/// OneMind OS Frontend Constants
/// ================================
///
/// Centralized constants for the frontend services layer to eliminate magic numbers
/// and improve maintainability.
///
/// Note: UI-related constants (colors, spacing, text styles) are in tactical_theme.dart
///
/// Categories:
/// - Network & API Configuration
/// - Timeouts & Retry Configuration
/// - Cache Configuration
/// - Health & Performance Thresholds
/// - Default Values & Limits
library;

// ============================================================================
// Network & API Configuration
// ============================================================================

/// API request timeouts
class ApiTimeouts {
  /// Standard API request timeout
  static const Duration standard = Duration(seconds: 30);

  /// Long-running requests (file uploads, large queries)
  static const Duration long = Duration(seconds: 120);

  /// Quick requests (health checks, pings)
  static const Duration quick = Duration(seconds: 5);

  /// SSE/streaming connection timeout
  static const Duration streaming = Duration(minutes: 30);

  /// WebSocket connection timeout
  static const Duration websocket = Duration(seconds: 10);
}

/// Retry configuration for failed requests
class RetryConfig {
  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Delay before first retry
  static const Duration initialDelay = Duration(milliseconds: 500);

  /// Delay multiplier for exponential backoff
  static const int backoffMultiplier = 2;

  /// Maximum delay between retries
  static const Duration maxDelay = Duration(seconds: 10);
}

/// WebSocket configuration
class WebSocketConfig {
  /// Reconnection delay after disconnect
  static const Duration reconnectDelay = Duration(seconds: 3);

  /// Maximum reconnection attempts
  static const int maxReconnectAttempts = 5;

  /// Ping interval to keep connection alive
  static const Duration pingInterval = Duration(seconds: 30);

  /// Timeout waiting for pong response
  static const Duration pongTimeout = Duration(seconds: 5);
}

// ============================================================================
// Cache Configuration
// ============================================================================

/// Cache TTL (Time To Live) durations for different data types
class CacheDuration {
  /// Very short-lived cache (real-time data)
  static const Duration veryShort = Duration(minutes: 1);

  /// Short-lived cache (frequently updated)
  static const Duration short = Duration(minutes: 5);

  /// Medium-lived cache (standard API data)
  static const Duration medium = Duration(minutes: 30);

  /// Long-lived cache (rarely changing data)
  static const Duration long = Duration(hours: 1);

  /// Very long-lived cache (static/reference data)
  static const Duration veryLong = Duration(hours: 24);

  /// Get cache duration for a specific endpoint pattern
  static Duration forEndpoint(String endpoint) {
    if (endpoint.contains('/agents') || endpoint.contains('/teams')) {
      return long; // Agent/team configs rarely change
    }
    if (endpoint.contains('/models')) {
      return veryLong; // Model list is static
    }
    if (endpoint.contains('/sessions') || endpoint.contains('/runs')) {
      return short; // Session data changes frequently
    }
    if (endpoint.contains('/stats') || endpoint.contains('/status')) {
      return veryShort; // Real-time stats
    }
    return medium; // Default
  }
}

/// Cache size limits
class CacheLimits {
  /// Maximum number of cached entries
  static const int maxEntries = 500;

  /// Maximum cache memory size (MB)
  static const int maxMemoryMB = 50;

  /// Percentage to keep when evicting
  static const double evictionKeepRatio = 0.7;
}

// ============================================================================
// Health & Performance Thresholds
// ============================================================================

/// Asset health calculation thresholds
class HealthThresholds {
  // Biometric thresholds
  /// Heart rate: minimum healthy BPM
  static const int heartRateMin = 50;

  /// Heart rate: maximum healthy BPM
  static const int heartRateMax = 120;

  /// Blood oxygen: minimum healthy percentage
  static const int bloodOxygenMin = 95;

  /// Blood oxygen: maximum percentage
  static const int bloodOxygenMax = 100;

  // Battery thresholds
  /// Battery level: critical (red)
  static const int batteryCritical = 15;

  /// Battery level: low (yellow)
  static const int batteryLow = 30;

  /// Battery level: good (green)
  static const int batteryGood = 70;

  // System performance
  /// CPU usage: warning threshold (%)
  static const int cpuWarning = 70;

  /// CPU usage: critical threshold (%)
  static const int cpuCritical = 90;

  /// Memory usage: warning threshold (%)
  static const int memoryWarning = 75;

  /// Memory usage: critical threshold (%)
  static const int memoryCritical = 90;

  // Response time thresholds (milliseconds)
  /// Response time: fast
  static const int responseTimeFast = 200;

  /// Response time: acceptable
  static const int responseTimeOk = 1000;

  /// Response time: slow (warning)
  static const int responseTimeSlow = 3000;

  /// Response time: critical
  static const int responseTimeCritical = 5000;
}

/// Opacity/alpha values for UI elements
class OpacityValues {
  /// Fully transparent
  static const double transparent = 0.0;

  /// Very light (subtle hints)
  static const double veryLight = 0.1;

  /// Light (disabled states)
  static const double light = 0.2;

  /// Medium-light (muted elements)
  static const double mediumLight = 0.3;

  /// Medium (secondary elements)
  static const double medium = 0.5;

  /// Medium-high (active secondary)
  static const double mediumHigh = 0.7;

  /// High (prominent elements)
  static const double high = 0.85;

  /// Very high (almost fully visible)
  static const double veryHigh = 0.95;

  /// Fully opaque
  static const double opaque = 1.0;
}

// ============================================================================
// Pagination & List Limits
// ============================================================================

/// Pagination and list display limits
class ListLimits {
  /// Default page size for lists
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 100;

  /// Initial load size (for infinite scroll)
  static const int initialLoadSize = 30;

  /// Items to load per scroll trigger
  static const int loadMoreSize = 20;

  /// Minimum items before showing "load more"
  static const int loadMoreThreshold = 5;
}

/// Search and filter configuration
class SearchConfig {
  /// Minimum characters before searching
  static const int minSearchLength = 2;

  /// Debounce delay for search input
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Maximum search results to show
  static const int maxResults = 50;
}

// ============================================================================
// Animation & UI Timing
// ============================================================================

/// UI animation and transition durations
class AnimationDuration {
  /// Very fast transition (button press)
  static const Duration veryFast = Duration(milliseconds: 50);

  /// Fast transition (hover effects)
  static const Duration fast = Duration(milliseconds: 100);

  /// Quick transition (menu open/close)
  static const Duration quick = Duration(milliseconds: 150);

  /// Normal transition (page transitions)
  static const Duration normal = Duration(milliseconds: 200);

  /// Slow transition (drawer slide)
  static const Duration slow = Duration(milliseconds: 300);

  /// Very slow transition (full screen)
  static const Duration verySlow = Duration(milliseconds: 400);

  /// Loading indicator delay before showing
  static const Duration loadingDelay = Duration(milliseconds: 200);

  /// Toast/snackbar duration
  static const Duration snackbarShort = Duration(seconds: 2);
  static const Duration snackbarMedium = Duration(seconds: 4);
  static const Duration snackbarLong = Duration(seconds: 6);
}

/// Debounce and throttle durations
class DebounceConfig {
  /// Standard input debounce
  static const Duration input = Duration(milliseconds: 300);

  /// Search input debounce
  static const Duration search = Duration(milliseconds: 500);

  /// Scroll debounce
  static const Duration scroll = Duration(milliseconds: 150);

  /// Button tap debounce (prevent double-tap)
  static const Duration tap = Duration(milliseconds: 500);

  /// API call throttle
  static const Duration apiCall = Duration(milliseconds: 1000);
}

// ============================================================================
// Default Values & Limits
// ============================================================================

/// Agent and team defaults
class AgentDefaults {
  /// Default agent model
  static const String defaultModel = 'gpt-4o';

  /// Default agent name
  static const String defaultName = 'Assistant';

  /// Maximum message length
  static const int maxMessageLength = 10000;

  /// Maximum messages in conversation
  static const int maxConversationLength = 100;
}

/// File upload limits
class FileUploadLimits {
  /// Maximum file size for images (MB)
  static const int maxImageSizeMB = 5;

  /// Maximum file size for documents (MB)
  static const int maxDocumentSizeMB = 10;

  /// Maximum file size for general uploads (MB)
  static const int maxUploadSizeMB = 50;

  /// Allowed image extensions
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg'
  ];

  /// Allowed document extensions
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
    'csv'
  ];
}

/// Validation patterns and limits
class ValidationLimits {
  /// Minimum name length
  static const int minNameLength = 1;

  /// Maximum name length
  static const int maxNameLength = 255;

  /// Minimum description length
  static const int minDescriptionLength = 0;

  /// Maximum description length
  static const int maxDescriptionLength = 1000;

  /// Email regex pattern
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// URL regex pattern
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
}

// ============================================================================
// Feature Flags (Local)
// ============================================================================

/// Feature flags for experimental features
class FeatureFlags {
  /// Enable debug mode features
  static const bool enableDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);

  /// Enable experimental features
  static const bool enableExperimental = bool.fromEnvironment('EXPERIMENTAL', defaultValue: false);

  /// Enable verbose logging
  static const bool enableVerboseLogging = bool.fromEnvironment('VERBOSE', defaultValue: false);

  /// Enable performance monitoring
  static const bool enablePerformanceMonitoring = true;

  /// Enable crash reporting
  static const bool enableCrashReporting = false; // Set to true in production
}

// ============================================================================
// Example Usage
// ============================================================================

// Before:
//   final response = await http.get(uri).timeout(Duration(seconds: 30));
//   if (heartRate > 120 || heartRate < 50) { /* warning */ }
//   await Future.delayed(Duration(milliseconds: 300));
//
// After:
//   final response = await http.get(uri).timeout(ApiTimeouts.standard);
//   if (heartRate > HealthThresholds.heartRateMax || heartRate < HealthThresholds.heartRateMin) { /* warning */ }
//   await Future.delayed(DebounceConfig.input);
