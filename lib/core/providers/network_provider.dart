import 'package:dio/dio.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/logging/logger_provider.dart';
import 'package:pocket_notes/core/network/interceptors/retry_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final logger = ref.watch(loggerProvider);
  final Dio dio = Dio();

  dio.options.baseUrl = AppConstants.apiBaseUrl;
  dio.options.connectTimeout = AppConstants.apiConnectTimeoutDuration;
  dio.options.receiveTimeout = AppConstants.apiReceiveTimeoutDuration;
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Logging Interceptor
  dio.interceptors.add(
    LogInterceptor(request: true, responseBody: true, error: true),
  );

  // Error Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onResponse: (response, handler) => handler.next(response),
      onError: (error, handler) => handler.next(error),
    ),
  );

  // Retry Interceptor
  dio.interceptors.add(RetryInterceptor(dio: dio, logger: logger));
  return dio;
}
