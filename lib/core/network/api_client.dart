import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

class ApiClient {
  // Instantiate Dio
  final Dio _dio = Dio();

  //  Get request
  Future<Either<Failure, Response>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return Right(response);
    } on DioException catch (e) {
      throw Left(_handleDioException(e));
    }
  }

  // Post request
  Future<Either<Failure, Response>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      throw Left(_handleDioException(e));
    }
  }

  // Put request
  Future<Either<Failure, Response>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      throw Left(_handleDioException(e));
    }
  }

  // Delete request
  Future<Either<Failure, Response>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      throw Left(_handleDioException(e));
    }
  }

  // Handle Dio Exceptions
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(message: "Request timed out");
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return ValidationFailure(message: "Bad request");
          case 401:
            return UnauthorizedFailure(message: "Unauthorized access");
          case 403:
            return ForbiddenFailure(message: "Forbidden access");
          case 404:
            return ServerFailure(message: "Resource not found");
          case 500:
          case 501:
          case 502:
          case 503:
            return ServerFailure(message: "Server error occurred");
          default:
            return UnknownFailure(message: "An unknown error occurred");
        }
      case DioExceptionType.badCertificate:
        return ServerFailure(message: "Bad certificate");
      case DioExceptionType.cancel:
        return ServerFailure(message: "Request was cancelled");
      case DioExceptionType.unknown:
        if (e.error.toString().contains("SocketException")) {
          return NetworkFailure(message: "No internet connection");
        }
        return UnknownFailure(message: "An unknown error occurred");
    }
  }

  // Add token to headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove token from headers
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
