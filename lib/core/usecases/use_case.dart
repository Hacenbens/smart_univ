import 'package:fpdart/fpdart.dart';
import 'package:smart_univ/core/error/app_exception.dart';

abstract interface class UseCase<Type, Params> {
  Future<Either<AppException, Type>> call(Params params);
}

/// Use this when a use case requires no parameters.
class NoParams {
  const NoParams();
}
