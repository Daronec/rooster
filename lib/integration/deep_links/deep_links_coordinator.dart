import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/integration/deep_links/deep_link_route_parser.dart';

/// Координатор deep links: слушает входящие URI и открывает экраны приложения.
///
/// Живёт на уровне приложения (scope) и освобождает подписки в [dispose].
final class DeepLinksCoordinator {
  /// Создаёт координатор для обработки входящих ссылок.
  DeepLinksCoordinator({
    required AppLinks appLinks,
    required AppRouter router,
    required ILogWriter logger,
  }) : _appLinks = appLinks,
       _router = router,
       _logger = logger;

  final AppLinks _appLinks;
  final AppRouter _router;
  final ILogWriter _logger;

  StreamSubscription<Uri>? _subscription;

  /// Подключить обработку initial link и подписку на stream ссылок.
  Future<void> initialize() async {
    await _handleInitialLink();

    _subscription ??= _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        if (kDebugMode) {
          _logger.log('deep_links_stream_error $error');
        }
      },
    );
  }

  /// Освобождает ресурсы (подписку на stream ссылок).
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) {
        return;
      }
      await _handleUri(uri);
    } on Object catch (error) {
      if (kDebugMode) {
        _logger.log('deep_links_initial_error $error');
      }
    }
  }

  Future<void> _handleUri(Uri uri) async {
    if (kDebugMode) {
      _logger.log('deep_link_received $uri');
    }

    final taskId = DeepLinkRouteParser.tryParseTaskId(uri);
    if (taskId == null || taskId.isEmpty) {
      return;
    }

    await _router.push<void>(CreateTaskRoute(taskId: taskId));
  }
}
