import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/network/auth_interceptor.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class _MockDio extends Mock implements Dio {}

class _MockTokenProvider extends Mock implements TokenProvider {}

class _MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

RequestOptions _opts({String path = '/test', Map<String, dynamic>? extra}) =>
    RequestOptions(path: path, extra: extra ?? {});

DioException _401(RequestOptions opts) => DioException(
      requestOptions: opts,
      response: Response(requestOptions: opts, statusCode: 401),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_opts());
    registerFallbackValue(
      Response<dynamic>(requestOptions: _opts(), statusCode: 200),
    );
    registerFallbackValue(DioException(requestOptions: _opts()));
    registerFallbackValue(Options());
  });

  late _MockDio mockDio;
  late _MockTokenProvider mockProvider;
  late _MockRequestInterceptorHandler requestHandler;
  late _MockErrorInterceptorHandler errorHandler;
  late AuthInterceptor interceptor;
  bool authExpiredCalled = false;

  setUp(() {
    mockDio = _MockDio();
    mockProvider = _MockTokenProvider();
    requestHandler = _MockRequestInterceptorHandler();
    errorHandler = _MockErrorInterceptorHandler();
    authExpiredCalled = false;
    interceptor = AuthInterceptor(
      dio: mockDio,
      tokenProvider: mockProvider,
      onAuthExpired: () => authExpiredCalled = true,
    );
  });

  group('onRequest', () {
    test('adds Authorization header when token is available', () async {
      when(() => mockProvider.getToken()).thenAnswer((_) async => 'valid_token');
      when(() => requestHandler.next(any())).thenReturn(null);

      final options = _opts();
      await interceptor.onRequest(options, requestHandler);

      expect(options.headers['Authorization'], 'Bearer valid_token');
      verify(() => requestHandler.next(options)).called(1);
    });

    test('skips Authorization header when token is null', () async {
      when(() => mockProvider.getToken()).thenAnswer((_) async => null);
      when(() => requestHandler.next(any())).thenReturn(null);

      final options = _opts();
      await interceptor.onRequest(options, requestHandler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => requestHandler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('passes non-401 errors through unchanged', () async {
      when(() => errorHandler.next(any())).thenReturn(null);

      final err = DioException(
        requestOptions: _opts(),
        response: Response(requestOptions: _opts(), statusCode: 404),
      );
      await interceptor.onError(err, errorHandler);

      verify(() => errorHandler.next(err)).called(1);
      verifyNever(() => mockProvider.refreshToken());
    });

    test('does not retry a request already marked as retry', () async {
      when(() => errorHandler.next(any())).thenReturn(null);

      final err = _401(_opts(extra: {'_auth_retry': true}));
      await interceptor.onError(err, errorHandler);

      verifyNever(() => mockProvider.refreshToken());
      verify(() => errorHandler.next(err)).called(1);
    });

    test('retries using the configured Dio instance, not a bare one', () async {
      when(() => mockProvider.refreshToken())
          .thenAnswer((_) async => 'fresh_token');
      when(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async =>
          Response(requestOptions: _opts(), statusCode: 200, data: {}));
      when(() => errorHandler.resolve(any())).thenReturn(null);

      await interceptor.onError(_401(_opts()), errorHandler);

      // Retry must go through the injected Dio, not a bare Dio().
      verify(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(1);
      verify(() => errorHandler.resolve(any())).called(1);
    });

    test('retry request carries fresh token and retry marker in Options',
        () async {
      when(() => mockProvider.refreshToken())
          .thenAnswer((_) async => 'fresh_token');
      when(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: captureAny(named: 'options'),
          )).thenAnswer((_) async =>
          Response(requestOptions: _opts(), statusCode: 200, data: {}));
      when(() => errorHandler.resolve(any())).thenReturn(null);

      await interceptor.onError(_401(_opts()), errorHandler);

      final captured = verify(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: captureAny(named: 'options'),
          )).captured;

      final retryOpts = captured.single as Options;
      expect(retryOpts.headers?['Authorization'], 'Bearer fresh_token');
      expect(retryOpts.extra?['_auth_retry'], isTrue);
    });

    test('retry does not mutate the original RequestOptions headers', () async {
      when(() => mockProvider.refreshToken())
          .thenAnswer((_) async => 'fresh_token');
      when(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async =>
          Response(requestOptions: _opts(), statusCode: 200, data: {}));
      when(() => errorHandler.resolve(any())).thenReturn(null);

      final original = _opts();
      original.headers['Authorization'] = 'Bearer old_token';
      await interceptor.onError(_401(original), errorHandler);

      expect(original.headers['Authorization'], 'Bearer old_token');
    });

    test('clears token and calls onAuthExpired when refresh returns null',
        () async {
      when(() => mockProvider.refreshToken()).thenAnswer((_) async => null);
      when(() => mockProvider.clearToken()).thenAnswer((_) async {});
      when(() => errorHandler.next(any())).thenReturn(null);

      await interceptor.onError(_401(_opts()), errorHandler);

      expect(authExpiredCalled, isTrue);
      verify(() => mockProvider.clearToken()).called(1);
      verify(() => errorHandler.next(any())).called(1);
    });

    test('concurrent 401s trigger only one token refresh', () async {
      final errorHandler1 = _MockErrorInterceptorHandler();
      final errorHandler2 = _MockErrorInterceptorHandler();
      when(() => errorHandler1.resolve(any())).thenReturn(null);
      when(() => errorHandler2.resolve(any())).thenReturn(null);

      final refreshCompleter = Completer<String?>();
      when(() => mockProvider.refreshToken())
          .thenAnswer((_) => refreshCompleter.future);
      when(() => mockDio.request<dynamic>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async =>
          Response(requestOptions: _opts(), statusCode: 200, data: {}));

      // Both 401s fire before the refresh completes.
      final f1 = interceptor.onError(_401(_opts()), errorHandler1);
      final f2 = interceptor.onError(_401(_opts()), errorHandler2);

      refreshCompleter.complete('shared_token');
      await Future.wait([f1, f2]);

      // Only one refresh call despite two simultaneous 401s.
      verify(() => mockProvider.refreshToken()).called(1);
      verify(() => errorHandler1.resolve(any())).called(1);
      verify(() => errorHandler2.resolve(any())).called(1);
    });
  });
}
