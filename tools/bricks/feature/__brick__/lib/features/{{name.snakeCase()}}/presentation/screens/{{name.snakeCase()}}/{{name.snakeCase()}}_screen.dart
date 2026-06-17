import 'package:auto_route/auto_route.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/{{name.snakeCase()}}/presentation/screens/{{name.snakeCase()}}/{{name.snakeCase()}}_wm.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

/// {@template {{name.snakeCase()}}_screen.class}
/// {{name.pascalCase()}}Screen.
/// {@endtemplate}
@RoutePage()
class {{name.pascalCase()}}Screen extends BaseWidget<I{{name.pascalCase()}}WM> {
  /// {@macro {{name.snakeCase()}}_screen.class}
  const {{name.pascalCase()}}Screen ({
    super.key,
    WidgetModelFactory wmFactory = default{{name.pascalCase()}}WMFactory,
  }) : super(wmFactory);

  @override
  Widget buildMobile(I{{name.pascalCase()}}WM wm) {
    // TODO: implement buildMobile
    throw UnimplementedError();
  }

  @override
  Widget buildDesktop(I{{name.pascalCase()}}WM wm) {
    // TODO: implement buildDesktop
    throw UnimplementedError();
  }
}
