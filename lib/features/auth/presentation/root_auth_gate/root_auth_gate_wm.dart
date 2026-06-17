import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_model.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_screen.dart';
import 'package:rooster/features/navigation/root_main_app_route.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Старт приложения: всегда основной UI со списком задач; экран входа открывается из профиля.
final class RootAuthGateWidgetModel
    extends BaseWidgetModel<RootAuthGateScreen, RootAuthGateModel> {
  /// Создаёт WM.
  RootAuthGateWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : bodyState = UnionStateNotifier<EmptyScreenBody>(EmptyScreenBody.instance),
       super(
         handledFailureLogWriter: logWriter,
       );

  /// Состояние тела экрана шлюза.
  final UnionStateNotifier<EmptyScreenBody> bodyState;

  bool _navigated = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _scheduleMain();
  }

  void _scheduleMain() {
    if (_navigated) {
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.router.replaceAll(rootMainAppStack(context));
    });
  }

  /// Повторить переход в основной граф (после ошибки на экране шлюза).
  void retryRootFlow() {
    _navigated = false;
    _scheduleMain();
  }

  @override
  void dispose() {
    bodyState.dispose();
    super.dispose();
  }
}
