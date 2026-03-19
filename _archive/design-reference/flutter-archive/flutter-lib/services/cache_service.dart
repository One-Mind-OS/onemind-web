/// HTTP Caching Service for API responses
///
/// Provides in-memory caching with configurable TTL (Time To Live) for different
/// endpoint types. Reduces unnecessary network requests and improves performance.
///
/// Cache Strategy:
/// - Models: 24 hours (rarely change)
/// - Tools: 12 hours (rarely change)
/// - Agents: 30 minutes (may change during development)
/// - Teams: 30 minutes (may change during development)
/// - Sessions/Memories: 5 minutes (frequently updated)
/// - Default: 5 minutes
library;

class CacheService {
  // In-memory cache storage
  static final Map<String, CachedResponse> _cache = {};

  /// Get cache duration based on endpoint path
  static Duration getCacheDuration(String endpoint) {
    // Long-lived data (rarely changes)
    if (endpoint.startsWith('/models')) {
      return const Duration(hours: 24);
    }
    if (endpoint.startsWith('/tools')) {
      return const Duration(hours: 12);
    }

    // Medium-lived data (changes occasionally)
    if (endpoint.startsWith('/agents') && !endpoint.contains('/runs')) {
      return const Duration(minutes: 30);
    }
    if (endpoint.startsWith('/teams') && !endpoint.contains('/runs')) {
      return const Duration(minutes: 30);
    }

    // Short-lived data (frequently updated)
    if (endpoint.startsWith('/sessions')) {
      return const Duration(minutes: 5);
    }
    if (endpoint.startsWith('/memories')) {
      return const Duration(minutes: 5);
    }
    if (endpoint.startsWith('/workflows')) {
      return const Duration(minutes: 10);
    }

    // Default: 5 minutes
    return const Duration(minutes: 5);
  }

  /// Get cached data if available and not expired
  static T? get<T>(String key) {
    final cached = _cache[key];

    // Cache miss
    if (cached == null) {
      return null;
    }

    // Cache expired
    if (DateTime.now().isAfter(cached.expiry)) {
      _cache.remove(key);
      return null;
    }

    // Cache hit
    return cached.data as T;
  }

  /// Set cached data with TTL
  static void set<T>(String key, T data, Duration ttl) {
    _cache[key] = CachedResponse(
      data: data,
      expiry: DateTime.now().add(ttl),
    );
  }

  /// Invalidate (remove) a specific cache entry
  static void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidate all cache entries matching a pattern
  static void invalidatePattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Clear all cached data
  static void clearAll() {
    _cache.clear();
  }

  /// Get cache statistics
  static CacheStats getStats() {
    int expired = 0;
    int valid = 0;
    final now = DateTime.now();

    for (final entry in _cache.values) {
      if (now.isAfter(entry.expiry)) {
        expired++;
      } else {
        valid++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: valid,
      expiredEntries: expired,
    );
  }

  /// Clean up expired cache entries
  static void cleanup() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.isAfter(entry.value.expiry))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}

/// Cached response data with expiry time
class CachedResponse {
  final dynamic data;
  final DateTime expiry;

  CachedResponse({
    required this.data,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Duration get timeToLive {
    final now = DateTime.now();
    if (isExpired) return Duration.zero;
    return expiry.difference(now);
  }
}

/// Cache statistics
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  double get hitRate {
    if (totalEntries == 0) return 0.0;
    return validEntries / totalEntries;
  }

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}
