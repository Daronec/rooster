import 'package:rooster/core/architecture/data/repository/base_repository.dart';
import 'package:rooster/features/{{name.snakeCase()}}/domain/repositories/i_{{name.snakeCase()}}_repository.dart';

/// {@template {{name.snakeCase()}}_repository.class}
/// Implementation of [I{{name.pascalCase()}}Repository].
/// {@endtemplate}
final class {{name.pascalCase()}}Repository extends BaseRepository implements I{{name.pascalCase()}}Repository {
  /// {@macro {{name.snakeCase()}}_repository.class}
  {{name.pascalCase()}}Repository({required super.logWriter});
}
