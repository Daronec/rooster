import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_controller.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/failures/api_failure.dart';
import 'package:rooster/uikit/buttons/app_button_scheme.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/sizes/app_sizes_scheme.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Typedef для кастомной обработки снеков.
typedef CustomErrorHandler = void Function()?;

/// Базовый интерфейс для всех [WidgetModel]ей.
// ignore: prefer-match-file-name
abstract interface class IBaseWidgetModel implements IWidgetModel {
  /// Цветовая схема.
  AppColorScheme get colorScheme;

  /// Схема шрифтов.
  AppTextScheme get textScheme;

  /// Схема кнопок.
  AppButtonScheme get buttonScheme;

  /// Схема размеров.
  AppSizesScheme get sizesScheme;

  /// [ThemeData].
  ThemeData get themeData;

  /// Является ли текущее устройство десктопным.
  bool get isDesktop;

  /// Является ли текущее устройство веб-приложением.
  bool get isWeb;
}

/// Базовый класс для всех [WidgetModel]ей.
abstract class BaseWidgetModel<
  W extends ElementaryWidget,
  M extends ElementaryModel
>
    extends WidgetModel<W, M>
    implements IBaseWidgetModel {

  /// Создать экземпляр [BaseWidgetModel].
  BaseWidgetModel(
    super._model, {
    required SnackQueueController snackController,
    ILogWriter? handledFailureLogWriter,
  }) : _snackController = snackController,
       _handledFailureLogWriter = handledFailureLogWriter;
  final SnackQueueController _snackController;

  /// Лог технических деталей ошибок API, обрабатываемых в [onErrorHandle].
  ///
  /// Сообщения снеков остаются пользовательскими (или обобщёнными); подробности —
  /// только здесь и в отладочном выводе при отсутствии [handledFailureLogWriter].
  final ILogWriter? _handledFailureLogWriter;

  /// Сервис для отображения снеков.
  @protected
  SnackQueueController get snackController => _snackController;

  @override
  AppColorScheme get colorScheme => context.appColorScheme;

  @override
  AppTextScheme get textScheme => context.appTextScheme;

  @override
  AppButtonScheme get buttonScheme => context.appButtonScheme;

  @override
  AppSizesScheme get sizesScheme => context.appSizesScheme;

  @override
  ThemeData get themeData => Theme.of(context);

  @override
  bool get isDesktop => context.isDesktop;

  @override
  bool get isWeb => kIsWeb;

  /// Записать технические детали ошибки отдельно от текста для пользователя.
  @protected
  void logHandledFailureSeparateFromUserMessage(Object error) {
    final writer = _handledFailureLogWriter;
    if (writer != null) {
      switch (error) {
        case Failure(:final original, :final trace):
          writer.exception(original, trace);
        default:
          writer.log('[BaseWidgetModel.onErrorHandle] $error');
      }
      return;
    }
    if (kDebugMode) {
      debugPrint('[BaseWidgetModel.onErrorHandle] $error');
    }
  }

  @override
  void onErrorHandle(Object error) {
    logHandledFailureSeparateFromUserMessage(error);

    switch (error) {
      case NoInternetFailure():
        _showSnack(message: 'Not Internet connection');
      case TimeoutFailure():
        _showSnack(message: 'TimeOut error');
      case ServerInternalFailure():
        _showSnack(message: 'Error');
      case ApiFailure():
        String? snackMessage;

        if (error.infoErrors.firstOrNull?.message case final String message
            when message.isNotEmpty) {
          snackMessage = message;
        }

        _showSnack(message: snackMessage ?? 'Error');
    }

    super.onErrorHandle(error);
  }

  /// Показать снек с сообщением.
  void _showSnack({required String message, SnackMessageType? messageType}) {
    _snackController.addSnack(
      message,
      messageType: messageType ?? SnackMessageType.error,
    );
  }
}

/// Extension for [BuildContext].
extension AdaptiveExt on BuildContext {
  /// Is current device display desktop format.
  bool get isDesktop {
    final screenSize = MediaQuery.sizeOf(this);

    final appSizes = Theme.of(this).extension<AppSizesScheme>();

    return screenSize.width > (appSizes?.mobileWidth ?? AppSizes.kMobileWidth);
  }
}
