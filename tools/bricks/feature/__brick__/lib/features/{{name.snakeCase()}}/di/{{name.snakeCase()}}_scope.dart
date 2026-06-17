import 'package:rooster/common/utils/disposable_object/disposable_object.dart';
import 'package:rooster/common/utils/disposable_object/i_disposable_object.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/{{name.snakeCase()}}/data/repositories/{{name.snakeCase()}}_repository.dart';
import 'package:rooster/features/{{name.snakeCase()}}/domain/repositories/i_{{name.snakeCase()}}_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// {@template {{name.snakeCase()}}_scope.class}
/// Implementation of [I{{name.pascalCase()}}Scope].
/// {@endtemplate}
final class {{name.pascalCase()}}Scope extends DisposableObject implements I{{name.pascalCase()}}Scope {
  @override
  final I{{name.pascalCase()}}Repository repository;

  /// Factory constructor for [I{{name.pascalCase()}}Scope].
  factory {{name.pascalCase()}}Scope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();

    final repository = {{name.pascalCase()}}Repository(logWriter: appScope.logger);

    return {{name.pascalCase()}}Scope(repository);
  }

  /// {@macro {{name.snakeCase()}}_scope.class}
  {{name.pascalCase()}}Scope(this.repository);

  @override
  void dispose() {
    repository.dispose();

    super.dispose();
  }
}

/// Scope dependencies of the {{name.pascalCase()}} feature.
abstract interface class I{{name.pascalCase()}}Scope implements IDisposableObject {
  /// {{name.pascalCase()}}Repository.
  I{{name.pascalCase()}}Repository get repository;
}
