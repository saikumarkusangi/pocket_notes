abstract class AppException implements Exception {
    final String message;
    final String? prefix;

    AppException({required this.message, this.prefix});

    @override
    String toString() {
        return prefix != null ? '$prefix: $message' : message;
    }
}

// Network Exceptions
class NetworkException extends AppException {
    NetworkException({required String message}) : super(message: message, prefix: "Network Error");
}

// Server Exceptions
class ServerException extends AppException {
    ServerException({required String message}) : super(message: message, prefix: "Server Error");
}

// Timeout Exceptions
class TimeoutException extends AppException {
    TimeoutException({required String message}) : super(message: message, prefix: "Timeout Error");
}

// Authentication Exceptions
class AuthenticationException extends AppException {
    AuthenticationException({required String message}) : super(message: message, prefix: "Authentication Error");
}

class UnauthorizedException extends AuthenticationException {
    UnauthorizedException({required String message}) : super(message: message);
}

class ForbiddenException extends AuthenticationException {
    ForbiddenException({required String message}) : super(message: message);
}

// Validation Exceptions
class ValidationException extends AppException {
    ValidationException({required String message}) : super(message: message, prefix: "Validation Error");
}

// Input Exceptions
class InputException extends AppException {
    InputException({required String message}) : super(message: message, prefix: "Input Error");
}

// Cache Exceptions
class CacheException extends AppException {
    CacheException({required String message}) : super(message: message, prefix: "Cache Error");
}

// Unknown Exceptions
class UnknownException extends AppException {
    UnknownException({required String message}) : super(message: message, prefix: "Unknown Error");
}

// Conflict Exceptions
class ConflictException extends AppException {
    ConflictException({required String message}) : super(message: message, prefix: "Conflict Error");
}

// Sync Exceptions
class SyncException extends AppException {
    SyncException({required String message}) : super(message: message, prefix: "Sync Error");
}