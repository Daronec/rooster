import 'package:flutter_i18n/flutter_i18n.dart';

/// Делегат пакета [flutter_i18n] для загрузки JSON из [assets/flutter_i18n/].
///
/// Базовый язык — `ru.json`; для остальных локалей (например `en`) подмешиваются
/// недостающие ключи из `ru`.
final FlutterI18nDelegate appFlutterI18nDelegate = FlutterI18nDelegate(
  translationLoader: FileTranslationLoader(
    fallbackFile: 'ru',
  ),
);
