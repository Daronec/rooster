import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/{{feature_name.snakeCase()}}/di/{{feature_name.snakeCase()}}_scope.dart';
import 'package:rooster/features/{{feature_name.snakeCase()}}/presentation/screens/{{screen_name.snakeCase()}}/{{screen_name.snakeCase()}}_model.dart';
import 'package:rooster/features/{{feature_name.snakeCase()}}/presentation/screens/{{screen_name.snakeCase()}}/{{screen_name.snakeCase()}}_screen.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// DI factory for [{{screen_name.pascalCase()}}WM].
{{screen_name.pascalCase()}}WM default{{screen_name.pascalCase()}}WMFactory(BuildContext context) {
  final scope = context.read<I{{feature_name.pascalCase()}}Scope>();
  final snackController = SnackQueueProvider.of(context);

  return {{screen_name.pascalCase()}}WM(
    {{screen_name.pascalCase()}}Model(repository: scope.repository),
    snackController: snackController,
  );
}

/// Interface for [{{screen_name.pascalCase()}}WM].
abstract interface class I{{screen_name.pascalCase()}}WM implements IBaseWidgetModel {}

/// {@template {{screen_name.snakeCase()}}_wm.class}
/// [WidgetModel] for [{{screen_name.pascalCase()}}Screen].
/// {@endtemplate}
final class {{screen_name.pascalCase()}}WM extends BaseWidgetModel<{{screen_name.pascalCase()}}Screen, {{screen_name.pascalCase()}}Model> implements I{{screen_name.pascalCase()}}WM {
  /// {@macro {{screen_name.snakeCase()}}_wm.class}
  {{screen_name.pascalCase()}}WM(
    super._model, {
    required super.snackController,
  });
}
