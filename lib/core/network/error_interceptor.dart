import 'package:dio/dio.dart';
import 'package:smart_univ/core/error/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    throw _mapToAppException(err);
  }

  AppException _mapToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out');
      case DioExceptionType.badResponse:
        return _mapStatusCode(err.response?.statusCode);
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      default:
        return NetworkException(err.message ?? 'Unexpected network error');
    }
  }

  AppException _mapStatusCode(int? statusCode) {
    if (statusCode == 404) return const NetworkException('Not found');
    if (statusCode == 401) return const AuthException('Unauthorized');
    if (statusCode != null && statusCode >= 500) {
      return const NetworkException('Server error');
    }
    return NetworkException('Request failed with status $statusCode');
  }
}
