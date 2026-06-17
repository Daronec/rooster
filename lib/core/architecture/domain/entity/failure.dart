/// {@template failure.class}
/// The failure processed in the business logic layer of the application.
///
/// It is mostly returned from repository methods.
/// {@endtemplate}
base class Failure<T extends Exception> implements Exception {

  /// {@macro failure.class}
  const Failure({required this.original, required this.trace});
  /// Original error.
  final T original;

  /// Stack Trace.
  final StackTrace? trace;
}
