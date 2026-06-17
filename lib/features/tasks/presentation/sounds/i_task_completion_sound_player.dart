/// Проигрыватель UI-звука завершения задачи.
abstract interface class ITaskCompletionSoundPlayer {
  /// Проиграть звук завершения задачи.
  Future<void> playDoneTask();

  /// Освободить ресурсы проигрывателя.
  Future<void> dispose();
}
