import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/{{name.snakeCase()}}/di/{{name.snakeCase()}}_scope.dart';
import 'package:rooster/features/{{name.snakeCase()}}/presentation/screens/{{name.snakeCase()}}/{{name.snakeCase()}}_model.dart';
import 'package:rooster/features/{{name.snakeCase()}}/presentation/screens/{{name.snakeCase()}}/{{name.snakeCase()}}_screen.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// DI factory for [{{name.pascalCase()}}WM].
{{name.pascalCase()}}WM default{{name.pascalCase()}}WMFactory(BuildContext context) {
  final scope = context.read<I{{name.pascalCase()}}Scope>();
  final snackController = SnackQueueProvider.of(context);

  return {{name.pascalCase()}}WM(
    {{name.pascalCase()}}Model(repository: scope.repository),
    snackController: snackController,
  );
}

/// Interface for [{{name.pascalCase()}}WM].
abstract interface class I{{name.pascalCase()}}WM implements IBaseWidgetModel {}

/// {@template {{name.snakeCase()}}_wm.class}
/// [WidgetModel] for [{{name.pascalCase()}}Screen].
/// {@endtemplate}
final class {{name.pascalCase()}}WM extends BaseWidgetModel<{{name.pascalCase()}}Screen, {{name.pascalCase()}}Model> implements I{{name.pascalCase()}}WM {

  /// {@macro {{name.snakeCase()}}_wm.class}
  {{name.pascalCase()}}WM(
    super._model, {
    required super.snackController,
  });
}
