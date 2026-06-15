// Interceptor that retries failed requests
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/logging/logger.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger;
  RetryInterceptor({required this.dio, required this.logger});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final attempt = err.requestOptions.headers['retry_attempt'] ?? 0;

      if (attempt < AppConstants.apiMaxRetryCount &&
          attempt < AppConstants.apiRetryDelays.length) {
        final delay = AppConstants.apiRetryDelays[attempt];
        logger.info(
          '🔄 Retry attempt ${attempt + 1}/${AppConstants.apiMaxRetryCount} for ${err.requestOptions.path} after ${delay.inSeconds}s',
        );

        // Update retry attempt count
        err.requestOptions.headers['retry_attempt'] = attempt + 1;

        // Wait before retrying
        await Future.delayed(delay);

        try {
          // Clone the request and retry
          final options = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            followRedirects: err.requestOptions.followRedirects,
            listFormat: err.requestOptions.listFormat,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            validateStatus: err.requestOptions.validateStatus,
            extra: err.requestOptions.extra,
          );

          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            cancelToken: err.requestOptions.cancelToken,
            options: options,
            onSendProgress: err.requestOptions.onSendProgress,
            onReceiveProgress: err.requestOptions.onReceiveProgress,
          );

          return handler.resolve(response);
        } catch (e) {
          // If retry fails, passed error will be handled by next error
          return super.onError(err, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.type == DioExceptionType.unknown &&
            err.error != null &&
            err.error is SocketException);
  }
}
