import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/tasks/presentation/sounds/i_task_completion_sound_player.dart';

/// Проигрыватель звука завершения задачи из assets.
final class TaskCompletionSoundPlayer implements ITaskCompletionSoundPlayer {
  /// Создаёт проигрыватель.
  TaskCompletionSoundPlayer({required ILogWriter logger}) : _logger = logger;

  static const String _doneTaskAssetPath = 'sound/done_task.mp3';

  final ILogWriter _logger;
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playDoneTask() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_doneTaskAssetPath));
    } on Object catch (error, stackTrace) {
      if (kDebugMode) {
        _logger.log('task_completion_sound_skip ${error.runtimeType}: $error');
        _logger.exception(error, stackTrace);
      }
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } on Object catch (error, stackTrace) {
      if (kDebugMode) {
        _logger.log('task_completion_sound_dispose_skip $error');
        _logger.exception(error, stackTrace);
      }
    }
  }
}
