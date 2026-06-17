import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/default_snack_controller.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_controller.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_widget.dart';
import 'package:rooster/common/utils/snack_queue/presentation/top_snack_bar.dart';
import 'package:rooster/core/architecture/presentation/empty_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/util/async/safe_unawaited.dart';
import 'package:rxdart/rxdart.dart';

/// DI factory for [SnackQueueWM].
SnackQueueWM defaultSnackQueueWMFactory(BuildContext context) {
  final router = context.read<AppRouter>();

  return SnackQueueWM(EmptyModel(), router, const DefaultSnackController());
}

/// Interface for [SnackQueueWM].
abstract interface class ISnackQueueWM
    implements SnackQueueController, IWidgetModel {}

/// {@template snack_provider_wm.class}
/// [WidgetModel] for [SnackQueueWidget].
/// {@endtemplate}
final class SnackQueueWM extends WidgetModel<SnackQueueWidget, EmptyModel>
    implements ISnackQueueWM {

  /// {@macro snack_provider_wm.class}
  SnackQueueWM(super._model, this._router, this._snackController);
  /// Controller for displaying dialogs.
  final DefaultSnackController _snackController;

  final AppRouter _router;

  /// Queue of snacks.
  final _snackQueue = Queue<TopSnackBar>();

  final _currentRouterSubject = BehaviorSubject<String>();

  /// Controller for displaying dialogs.
  Completer<void>? _completer;

  bool _hasOpenedSnack = false;

  /// Stream with snacks.
  late final BehaviorSubject<TopSnackBar> _snackStream;

  late final StreamSubscription<List<String>> _currentRouterSubscription;

  @override
  Future<void> initWidgetModel() async {
    super.initWidgetModel();

    _router.addListener(_listenRouter);
    _currentRouterSubscription = _currentRouterSubject.pairwise().listen(
      _currentRouterListener,
      onError: (Object e, StackTrace st) {
        developer.log(
          'SnackQueueWM: router pairwise stream',
          error: e,
          stackTrace: st,
        );
      },
    );
    _snackStream = BehaviorSubject<TopSnackBar>()
      ..stream
          .asyncMap(_showSnackBarDelayed)
          .listen(
            (_) {},
            onError: (Object e, StackTrace st) {
              developer.log(
                'SnackQueueWM: snack asyncMap stream',
                error: e,
                stackTrace: st,
              );
            },
          );
  }

  @override
  void dispose() {
    _router.removeListener(_listenRouter);
    safeUnawaited(_currentRouterSubscription.cancel());
    safeUnawaited(_currentRouterSubject.close());
    safeUnawaited(_snackStream.close());
    super.dispose();
  }

  @override
  void addSnack(
    String message, {
    required SnackMessageType messageType,
    EasyDialogDecoration? dialogDecoration,
    EasyDialogAnimationConfiguration? animationConfiguration,
  }) {
    _addToQueue(
      TopSnackBar(
        message: message,
        messageType: messageType,
        dialogDecoration: dialogDecoration,
        animationConfiguration: animationConfiguration,
      ),
    );
  }

  /// Clears the snack queue from possible display, which were put in the queue before [closeTime].
  @override
  void clearSnackQueue(DateTime closeTime) {
    _snackQueue.removeWhere(
      /// Subtract a second so that snacks are displayed when the screen is closed.
      (snackData) => snackData.showTime.isBefore(
        closeTime.add(const Duration(seconds: -1)),
      ),
    );
  }

  void _addToQueue(TopSnackBar snack) {
    _snackStream.add(snack);
    _snackQueue.add(snack);
  }

  void _listenRouter() {
    _currentRouterSubject.add(_router.current.name);
  }

  /// When the router changes, we clear the snack queue.
  void _currentRouterListener(List<String> pair) {
    final list = pair.nonNulls;
    if (list.isEmpty) return;

    final areObjectsEqual = list.every((obj) {
      final first = list.firstOrNull;
      if (first == null) return false;

      return obj == first;
    });

    if (areObjectsEqual) return;
    _clearSnackQueue();
  }

  /// Clears the snack queue.
  /// When the screen is closed, all snacks should be closed.
  void _clearSnackQueue() {
    if (_snackQueue.isEmpty) return;
    _snackQueue.clear();
    if (_hasOpenedSnack) {
      safeUnawaited(_snackController.hideSnack());
    }
  }

  Future<void> _showSnackBarDelayed(TopSnackBar snack) async {
    await _completer?.future;

    if (_snackQueue.isEmpty || _snackQueue.firstOrNull != snack) return;

    _completer = Completer()
      ..complete(
        Future.any<void>([_showTopSnack(snack)]).whenComplete(() {
          _hasOpenedSnack = false;
          if (_snackQueue.isNotEmpty) {
            final _ = _updateSnackQueue();
          }
        }),
      );
  }

  /// Removes the displayed snack from the snack queue.
  TopSnackBar _updateSnackQueue() {
    return _snackQueue.removeFirst();
  }

  static const _autoHideDuration = Duration(seconds: 3);

  /// Calls the controller to show a snack.
  Future<void> _showTopSnack(TopSnackBar snackBar) async {
    _hasOpenedSnack = true;

    await _snackController.showSnack(
      messageType: snackBar.messageType,
      message: snackBar.message,
      context: context,
      dialogDecoration: snackBar.dialogDecoration,
      animationConfiguration: snackBar.animationConfiguration,
      autoHideDuration: _autoHideDuration,
    );
  }
}
