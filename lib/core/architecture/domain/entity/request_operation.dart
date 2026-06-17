import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';

/// Typedef for all methods that may fail.
/// These are mostly repository methods.
typedef RequestOperation<T, F extends Failure<Exception>> =
    Future<Result<T, F>>;

/// Typedef for all api operations.
typedef ApiOperation<T> = RequestOperation<T, Failure>;
