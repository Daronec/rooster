import 'package:rooster/core/architecture/data/repository/i_base_repository.dart';
import 'package:rooster/features/{{name.snakeCase()}}/data/repositories/{{name.snakeCase()}}_repository.dart';

/// Interface for [{{name.pascalCase()}}Repository].
// TODO(anyone): Explain what this repository is used for.
abstract interface class I{{name.pascalCase()}}Repository implements IBaseRepository {}
