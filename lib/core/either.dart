/// Lightweight Either monad — no external package needed.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) =>
      switch (this) {
        Left<L, R>(value: final l) => onLeft(l),
        Right<L, R>(value: final r) => onRight(r),
      };
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

Either<L, R> left<L, R>(L value) => Left(value);
Either<L, R> right<L, R>(R value) => Right(value);

/// Equivalent of void in an Either right side.
final class Unit {
  const Unit._();
  static const instance = Unit._();
}

const unit = Unit.instance;
