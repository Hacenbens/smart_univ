import 'package:dio/dio.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;
  final void Function() onAuthExpired;

  AuthInterceptor({
    required TokenProvider tokenProvider,
    required this.onAuthExpired,
  }) : _tokenProvider = tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final newToken = await _tokenProvider.refreshToken();

    if (newToken == null) {
      await _tokenProvider.clearToken();
      onAuthExpired();
      return handler.next(err);
    }

    // Retry the original request once with the new token
    try {
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';

      final response = await Dio().fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      await _tokenProvider.clearToken();
      onAuthExpired();
      return handler.next(e);
    }
  }
}
