import 'package:auto_route/auto_route.dart';
import 'package:rooster/features/{{name.snakeCase()}}/di/{{name.snakeCase()}}_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// {@template {{name.snakeCase()}}_flow.class}
/// Entry point to feature {{name.pascalCase()}}.
/// {@endtemplate}
@RoutePage()
class {{name.pascalCase()}}Flow extends StatelessWidget implements AutoRouteWrapper {
  /// {@macro {{name.snakeCase()}}_flow.class}
  const {{name.pascalCase()}}Flow({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<I{{name.pascalCase()}}Scope>(
      create: {{name.pascalCase()}}Scope.create,
      dispose: (ctx, scope) => scope.dispose(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
