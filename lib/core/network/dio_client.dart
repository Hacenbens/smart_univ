import 'package:dio/dio.dart';
import 'package:smart_univ/core/constants/app_constants.dart';
import 'package:smart_univ/core/network/auth_interceptor.dart';
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
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onAuthExpired: onAuthExpired,
      ),
    );
  }
}
