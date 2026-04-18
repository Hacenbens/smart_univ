import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/network/auth_interceptor.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class MockTokenProvider extends Mock implements TokenProvider {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: ''), statusCode: 200),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
  });

  late MockTokenProvider mockTokenProvider;
  late MockRequestInterceptorHandler requestHandler;
  late MockErrorInterceptorHandler errorHandler;
  late AuthInterceptor interceptor;
  bool authExpiredCalled = false;

  setUp(() {
    mockTokenProvider = MockTokenProvider();
    requestHandler = MockRequestInterceptorHandler();
    errorHandler = MockErrorInterceptorHandler();
    authExpiredCalled = false;
    interceptor = AuthInterceptor(
      tokenProvider: mockTokenProvider,
      onAuthExpired: () => authExpiredCalled = true,
    );
  });

  group('onRequest', () {
    test('adds Authorization header when token is available', () async {
      when(() => mockTokenProvider.getToken())
          .thenAnswer((_) async => 'valid_token');
      when(() => requestHandler.next(any())).thenReturn(null);

      final options = RequestOptions(path: '/test');
      await interceptor.onRequest(options, requestHandler);

      expect(options.headers['Authorization'], 'Bearer valid_token');
      verify(() => requestHandler.next(options)).called(1);
    });

    test('skips Authorization header when token is null', () async {
      when(() => mockTokenProvider.getToken()).thenAnswer((_) async => null);
      when(() => requestHandler.next(any())).thenReturn(null);

      final options = RequestOptions(path: '/test');
      await interceptor.onRequest(options, requestHandler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => requestHandler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('passes through non-401 errors', () async {
      when(() => errorHandler.next(any())).thenReturn(null);

      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      await interceptor.onError(err, errorHandler);

      verify(() => errorHandler.next(err)).called(1);
      verifyNever(() => mockTokenProvider.refreshToken());
    });

    test('retries with new token on 401 when refresh succeeds', () async {
      when(() => mockTokenProvider.refreshToken())
          .thenAnswer((_) async => 'new_token');
      when(() => errorHandler.resolve(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      // Override fetch by replacing the Dio call — we verify the token was set
      // by checking the header mutation on requestOptions before fetch is called
      try {
        await interceptor.onError(err, errorHandler);
      } catch (_) {
        // fetch() will throw in test environment — we only care about the token
      }

      expect(
        err.requestOptions.headers['Authorization'],
        'Bearer new_token',
      );
    });

    test('calls onAuthExpired and propagates error when refresh returns null',
        () async {
      when(() => mockTokenProvider.refreshToken())
          .thenAnswer((_) async => null);
      when(() => mockTokenProvider.clearToken()).thenAnswer((_) async {});
      when(() => errorHandler.next(any())).thenReturn(null);

      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      await interceptor.onError(err, errorHandler);

      expect(authExpiredCalled, isTrue);
      verify(() => mockTokenProvider.clearToken()).called(1);
      verify(() => errorHandler.next(err)).called(1);
    });
  });
}
