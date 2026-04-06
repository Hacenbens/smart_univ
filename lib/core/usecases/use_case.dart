import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';

abstract interface class UseCase<T, Params> {
  Future<Either<AppException, T>> call(Params params);
}

/// Use this when a use case requires no parameters.
class NoParams {
  const NoParams();
}
