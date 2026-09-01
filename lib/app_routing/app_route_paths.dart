/// Сегменты URL без привязки к экранам (см. `docs/NAVIGATION_AND_FEATURES.md`).
abstract class AppRoutePaths {
  /// Корень.
  static const String root = '/';

  /// Авторизация.
  static const String authFlow = '/auth-flow';

  /// Экран входа.
  static const String auth = 'auth';

  /// Регистрация (email, пароль, имя, телефон).
  static const String register = 'register';

  /// Основной flow с вкладками.
  static const String mainFlow = '/main-flow';

  /// Вкладка «Решения» (вложенный flow: сегодня / заблокировано / ресурсы).
  static const String decisionFlow = 'decisions';

  /// Dev-панель (мобильный корень).
  static const String devPanelFlow = '/dev-sync';

  /// Вложенный экран dev.
  static const String devPanel = 'dev-panel';

  /// AI Chat.
  static const String aiChat = 'ai-chat';
}
