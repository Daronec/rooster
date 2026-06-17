/// События аналитики продукта (HMS Analytics Kit и т.д.; облачная аналитика Firebase отключена).
abstract interface class IAppAnalyticsGateway {
  /// Старт приложения / сессии.
  Future<void> logAppOpen();

  /// Создание новой задачи.
  Future<void> logCreateTask();

  /// Завершение задачи.
  Future<void> logCompleteTask();

  /// Удаление задачи.
  Future<void> logDeleteTask();
}
