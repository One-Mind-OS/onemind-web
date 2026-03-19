/// Environment configuration for OneMind OS v2
///
/// Reads API base URL from environment variable (passed from Docker).
/// Supports both Docker container networking and local development.
class Environment {
  /// Base URL for API calls
  /// - Production: Railway backend (from API_BASE_URL env var)
  /// - Local dev: http://localhost:7777 (default)
  static String get apiBaseUrl {
    // Read from --dart-define passed during build
    const envUrl = String.fromEnvironment('API_BASE_URL');

    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Production default (Railway backend)
    const prodUrl = String.fromEnvironment('PROD', defaultValue: 'false');
    if (prodUrl == 'true') {
      return 'https://backend-production-08f44.up.railway.app';
    }

    // Default for local development
    return 'http://localhost:7777';
  }

  /// WebSocket URL (derived from API base URL)
  static String get websocketUrl {
    final baseUrl = apiBaseUrl;
    // Convert http:// to ws://
    final wsUrl = baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    return '$wsUrl/api/ws';
  }
}
