import 'package:auto_route/auto_route.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/{{feature_name.snakeCase()}}/presentation/screens/{{screen_name.snakeCase()}}/{{screen_name.snakeCase()}}_wm.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

/// {@template {{screen_name.snakeCase()}}_screen.class}
/// [{{screen_name.pascalCase()}}Screen].
/// {@endtemplate}
@RoutePage()
class {{screen_name.pascalCase()}}Screen extends BaseWidget<I{{screen_name.pascalCase()}}WM> {
  /// {@macro {{screen_name.snakeCase()}}_screen.class}
  const {{screen_name.pascalCase()}}Screen ({
    super.key,
    WidgetModelFactory wmFactory = default{{screen_name.pascalCase()}}WMFactory,
  }) : super(wmFactory);

  @override
  Widget buildMobile(I{{screen_name.pascalCase()}}WM wm) {
    // TODO: implement buildMobile
    throw UnimplementedError();
  }

  @override
  Widget buildDesktop(I{{screen_name.pascalCase()}}WM wm) {
    // TODO: implement buildDesktop
    throw UnimplementedError();
  }
}
