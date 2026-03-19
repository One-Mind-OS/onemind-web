/// Custom exception types for API errors
///
/// Provides user-friendly error messages and structured error handling
/// for the OneMind OS v2 frontend.
library;

/// Base API exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, [this.statusCode, this.details]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }

  /// Get user-friendly error message based on status code
  String get userFriendlyMessage {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable.';
      default:
        return message;
    }
  }
}

/// Network-related exception (connection issues, DNS failures, etc.)
class NetworkException extends ApiException {
  NetworkException(super.message);

  @override
  String get userFriendlyMessage =>
      'Network error. Please check your internet connection.';
}

/// Request timeout exception
class TimeoutException extends ApiException {
  final Duration timeout;

  TimeoutException(super.message, this.timeout);

  @override
  String get userFriendlyMessage =>
      'Request timed out after ${timeout.inSeconds} seconds. Please try again.';
}

/// Parse exception (invalid JSON, unexpected response format)
class ParseException extends ApiException {
  ParseException(String message, [String? details])
      : super(message, null, details);

  @override
  String get userFriendlyMessage =>
      'Failed to process server response. Please try again.';
}

/// Validation exception (client-side validation failed)
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException(String message, [this.fieldErrors])
      : super(message, 400);

  @override
  String get userFriendlyMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstError = fieldErrors!.values.first.first;
      return firstError;
    }
    return message;
  }

  /// Get all validation errors as a formatted string
  String get allErrors {
    if (fieldErrors == null || fieldErrors!.isEmpty) {
      return message;
    }

    final buffer = StringBuffer();
    fieldErrors!.forEach((field, errors) {
      buffer.writeln('$field: ${errors.join(', ')}');
    });
    return buffer.toString().trim();
  }
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, 401);

  @override
  String get userFriendlyMessage =>
      'Authentication required. Please log in again.';
}

/// Forbidden exception (403)
class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Forbidden']) : super(message, 403);

  @override
  String get userFriendlyMessage =>
      'You don\'t have permission to perform this action.';
}

/// Not found exception (404)
class NotFoundException extends ApiException {
  final String? resourceType;

  NotFoundException(String message, [this.resourceType])
      : super(message, 404);

  @override
  String get userFriendlyMessage {
    if (resourceType != null) {
      return '$resourceType not found.';
    }
    return 'Resource not found.';
  }
}

/// Rate limit exception (429)
class RateLimitException extends ApiException {
  final int? retryAfterSeconds;

  RateLimitException(String message, [this.retryAfterSeconds])
      : super(message, 429);

  @override
  String get userFriendlyMessage {
    if (retryAfterSeconds != null) {
      return 'Too many requests. Please wait $retryAfterSeconds seconds and try again.';
    }
    return 'Too many requests. Please wait and try again.';
  }
}

/// Server error exception (500)
class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);

  @override
  String get userFriendlyMessage =>
      'Server error occurred. Our team has been notified. Please try again later.';
}

/// Service unavailable exception (503)
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException(String message) : super(message, 503);

  @override
  String get userFriendlyMessage =>
      'Service is temporarily unavailable. Please try again in a few minutes.';
}
