import 'package:dio/dio.dart';
import 'package:smart_univ/core/constants/app_constants.dart';
import 'package:smart_univ/core/network/auth_interceptor.dart';
import 'package:smart_univ/core/network/error_interceptor.dart';
import 'package:smart_univ/core/network/logging_interceptor.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class DioClient {
  final Dio dio;

  DioClient({
    required TokenProvider tokenProvider,
    required void Function() onAuthExpired,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    // Registration order: Error → Auth → Logging
    // Dio runs onRequest in registration order, onError in reverse order.
    // Reverse error order: Logging → Auth → Error, so ErrorInterceptor
    // catches last — after AuthInterceptor has had a chance to retry on 401.
    dio.interceptors.addAll([
      ErrorInterceptor(),
      AuthInterceptor(
        dio: dio,
        tokenProvider: tokenProvider,
        onAuthExpired: onAuthExpired,
      ),
      LoggingInterceptor(),
    ]);
  }
}
