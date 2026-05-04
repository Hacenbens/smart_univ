import 'dart:async';

import 'package:dio/dio.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenProvider _tokenProvider;
  final void Function() onAuthExpired;

  // Marks a request as already-retried so a second 401 doesn't loop forever.
  static const _retryKey = '_auth_retry';

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required Dio dio,
    required TokenProvider tokenProvider,
    required this.onAuthExpired,
  })  : _dio = dio,
        _tokenProvider = tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider.getToken();
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
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra[_retryKey] == true) {
      return handler.next(err);
    }

    final newToken = await _acquireRefreshedToken();

    if (newToken == null) {
      await _tokenProvider.clearToken();
      onAuthExpired();
      return handler.next(err);
    }

    return _retry(err.requestOptions, newToken, handler);
  }

  // Ensures only one refresh call is in flight at a time.
  // Concurrent 401s wait on the same Completer instead of hammering the IdP.
  Future<String?> _acquireRefreshedToken() async {
    if (_isRefreshing) return _refreshCompleter!.future;

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();
    try {
      final token = await _tokenProvider.refreshToken();
      _refreshCompleter!.complete(token);
      return token;
    } catch (_) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retry(
    RequestOptions original,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _dio.request<dynamic>(
        original.path,
        data: original.data,
        queryParameters: original.queryParameters,
        options: Options(
          method: original.method,
          headers: {...original.headers, 'Authorization': 'Bearer $token'},
          extra: {...original.extra, _retryKey: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      await _tokenProvider.clearToken();
      onAuthExpired();
      handler.next(e);
    }
  }
}
