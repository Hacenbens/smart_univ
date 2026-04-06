import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/either.dart';

void main() {
  group('Either', () {
    group('Right', () {
      test('isRight is true', () {
        final e = right<String, int>(42);
        expect(e.isRight, isTrue);
        expect(e.isLeft, isFalse);
      });

      test('fold returns onRight result', () {
        final e = right<String, int>(10);
        final result = e.fold((_) => -1, (v) => v * 2);
        expect(result, 20);
      });

      test('Right holds the correct value', () {
        final e = right<String, String>('hello');
        expect((e as Right).value, 'hello');
      });
    });

    group('Left', () {
      test('isLeft is true', () {
        final e = left<String, int>('error');
        expect(e.isLeft, isTrue);
        expect(e.isRight, isFalse);
      });

      test('fold returns onLeft result', () {
        final e = left<String, int>('oops');
        final result = e.fold((l) => l.toUpperCase(), (_) => 'ok');
        expect(result, 'OOPS');
      });

      test('Left holds the correct value', () {
        final e = left<String, int>('fail');
        expect((e as Left).value, 'fail');
      });
    });

    group('Unit', () {
      test('unit is a singleton', () {
        expect(identical(unit, unit), isTrue);
      });

      test('right<_, Unit> wraps unit correctly', () {
        final e = right<String, Unit>(unit);
        expect(e.isRight, isTrue);
        expect((e as Right).value, same(unit));
      });
    });
  });
}
