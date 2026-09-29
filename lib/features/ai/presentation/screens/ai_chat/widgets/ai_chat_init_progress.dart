import 'package:flutter/material.dart';
import 'package:rooster/features/ai/presentation/strings/ai_chat_strings.dart';

/// Виджет индикатора прогресса инициализации/скачивания модели.
///
/// Отображает прогресс-бар с процентом загрузки при скачивании LLM модели
/// или простой индикатор при инициализации уже скачанной модели.
class AiChatInitProgress extends StatelessWidget {
  /// Создаёт виджет индикатора.
  const AiChatInitProgress({
    super.key,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });

  /// Прогресс скачивания (0.0 - 1.0).
  final double downloadProgress;

  /// Скачивается ли модель в данный момент.
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (downloadProgress * 100).toInt().clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDownloading) ...[
            // Показываем прогресс-бар при скачивании
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress : null,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Процент загрузки
            Text(
              '$progress%',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Текст прогресса
            Text(
              AiChatStrings.modelDownloadProgress(context, percent: progress),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            // Просто индикатор загрузки без прогресса
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AiChatStrings.modelInitializing(context)),
          ],
        ],
      ),
    );
  }
}
