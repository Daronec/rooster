import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Наблюдатель навигации для логирования переходов по роутам.
class RouterLoggingObserver extends AutoRouterObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null || oldRoute != null) {
      _log('replace', newRoute ?? oldRoute, oldRoute);
    }
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    super.didInitTabRoute(route, previousRoute);
    _logRoute('tabInit', route);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    super.didChangeTabRoute(route, previousRoute);
    _logRoute('tabChange', route);
  }

  void _log(
    String action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    final name = route?.settings.name ?? 'unknown';
    final prevName = previousRoute?.settings.name;
    final path = _pathFromRoute(route);
    if (kDebugMode) {
      print(
        '[Router] $action: $name${prevName != null ? ' (from: $prevName)' : ''} path: $path',
      );
    }
  }

  void _logRoute(String action, TabPageRoute route) {
    final name = route.name;
    if (kDebugMode) {
      print('[Router] $action: $name');
    }
  }

  String _pathFromRoute(Route<dynamic>? route) {
    if (route == null) return '—';
    final settings = route.settings;
    if (settings is AutoRoutePage) {
      return settings.routeData.path;
    }
    return settings.name ?? '—';
  }
}
