import 'package:multiple_result/multiple_result.dart';

import '../network/failure_mapper.dart';
import 'failure.dart';
import 'error_reporter.dart';

/// Exactly one transport-to-Failure boundary; diagnostics cannot break Result.
Future<Result<T, Failure>> repositoryGuard<T>(
  Future<T> Function() run,
  ErrorReporter report,
) async {
  try {
    return Success(await run());
  } catch (error, stack) {
    final failure = mapFailure(error);
    if (failure is UnexpectedFailure) {
      try {
        report(error, stack);
      } catch (_) {
        /* Preserve Result. */
      }
    }
    return Error(failure);
  }
}
