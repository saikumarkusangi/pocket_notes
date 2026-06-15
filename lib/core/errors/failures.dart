import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}


// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "No internet connection", super.statusCode});
}


// Server Failures
class ServerFailure extends Failure {
  const ServerFailure({super.message = "Server error occurred", super.statusCode});
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = "Request timed out", super.statusCode});
}


// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = "Authentication failed", super.statusCode});
}

class UnauthorizedFailure extends AuthenticationFailure {
  const UnauthorizedFailure({super.message = "Unauthorized access", super.statusCode});
}

class ForbiddenFailure extends AuthenticationFailure {
  const ForbiddenFailure({super.message = "Forbidden access", super.statusCode});
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = "Validation error occurred", super.statusCode});
}

// Input Failures
class InputFailure extends Failure {
  const InputFailure({super.message = "Invalid input provided", super.statusCode});
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = "Cache error occurred", super.statusCode});
}

// Unknown Failures
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = "An unknown error occurred", super.statusCode});
}

// Conflict Failures
class ConflictFailure extends Failure {
  const ConflictFailure({super.message = "Data conflict occurred", super.statusCode});
}

// Sync Failures
class SyncFailure extends Failure {
  const SyncFailure({super.message = "Data synchronization failed", super.statusCode});
}

