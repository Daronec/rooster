// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана AI-чата (`ai.*` в JSON локализации).
final class AiChatStrings {
  AiChatStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.screenTitle');

  static String welcomeTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.welcomeTitle');

  static String welcomeSubtitle(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.welcomeSubtitle');

  static String inputHint(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.inputHint');

  static String modelInitializing(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelInitializing');

  static String modelPreparing(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelPreparing');

  static String modelLoadError(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelLoadError');

  static String modelNotReady(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelNotReady');

  static String generationError(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.generationError');

  static String genericError(BuildContext context, {required String error}) =>
      FlutterI18n.translate(
        context,
        'ai.genericError',
        translationParams: <String, String>{'error': error},
      );

  static String sendButtonTooltip(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.sendButtonTooltip');

  static String loadingResponse(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.loadingResponse');

  static String modelDownloadProgress(
    BuildContext context, {
    required int percent,
  }) {
    return FlutterI18n.translate(
      context,
      'ai.modelDownloadProgress',
      translationParams: <String, String>{'percent': '$percent'},
    );
  }

  // Диалог скачивания
  static String downloadDialogTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.downloadDialogTitle');

  static String downloadModelButton(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.downloadModelButton');

  static String cancel(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.cancel');

  // Выбор модели
  static String selectModelTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.selectModelTitle');

  static String noDownloadedModels(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.noDownloadedModels');

  static String yourModels(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.yourModels');

  static String modelError(BuildContext context, {required String error}) =>
      FlutterI18n.translate(
        context,
        'ai.modelError',
        translationParams: <String, String>{'error': error},
      );

  // Сообщения в чате
  static String modelLoadErrorChat(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelLoadErrorChat');

  static String modelNotLoadedChat(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelNotLoadedChat');

  // Индикаторы состояния
  static String modelReadyIndicator(BuildContext context, {required String modelName}) =>
      FlutterI18n.translate(
        context,
        'ai.modelReadyIndicator',
        translationParams: <String, String>{'name': modelName},
      );

  static String modelNotReadyIndicator(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.modelNotReadyIndicator');

  static String selectModelForWork(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.selectModelForWork');

  static String selectModelAction(BuildContext context) =>
      FlutterI18n.translate(context, 'ai.selectModelAction');
}
