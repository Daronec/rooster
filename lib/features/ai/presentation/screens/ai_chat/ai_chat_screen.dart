import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_model.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_wm.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/widgets/ai_chat_init_progress.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/widgets/ai_chat_input_field.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/widgets/ai_chat_message_bubble.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/widgets/ai_chat_welcome_message.dart';
import 'package:rooster/features/ai/presentation/strings/ai_chat_strings.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// Экран AI-ассистента.
@RoutePage(name: 'AiChatRoute')
class AiChatScreen extends BaseWidget<AiChatScreenWidgetModel> {
  /// Создаёт экран.
  const AiChatScreen({super.key}) : super(aiChatScreenWidgetModelFactory);

  @override
  Widget buildDesktop(AiChatScreenWidgetModel wm) => _AiChatScreenContent(wm: wm);

  @override
  Widget buildMobile(AiChatScreenWidgetModel wm) => _AiChatScreenContent(wm: wm);
}

/// Фабрика [AiChatScreenWidgetModel].
AiChatScreenWidgetModel aiChatScreenWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  return AiChatScreenWidgetModel(
    AiChatScreenModel(appScope: scope),
    snackController: SnackQueueProvider.of(context),
  );
}

/// Контент экрана AI-чата (общий для mobile/desktop).
class _AiChatScreenContent extends StatelessWidget {
  const _AiChatScreenContent({required this.wm});

  final AiChatScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AiChatStrings.screenTitle(context)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
        ),
        actions: [
          // Индикатор состояния модели
          if (wm.hasModelManager) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                wm.isModelReady
                    ? AiChatStrings.modelReadyIndicator(
                        context,
                        modelName: wm.selectedModelName ?? '',
                      )
                    : AiChatStrings.modelNotReadyIndicator(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: wm.isModelReady
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
              ),
            ),
          ],
          // Кнопка выбора модели
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: wm.state != AiChatState.loading
                ? () => wm.showModelSelector(context)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Показываем прогресс инициализации если загружаем
          if (wm.state == AiChatState.loading) ...[
            Expanded(
              child: AiChatInitProgress(
                downloadProgress: wm.downloadProgress,
                isDownloading: wm.isDownloading,
              ),
            ),
          ] else ...[
            Expanded(
              child: wm.messages.isEmpty
                  ? _buildWelcomeScreen(context, wm)
                  : ListView.builder(
                      reverse: true,
                      itemCount: wm.messages.length,
                      itemBuilder: (_, i) =>
                          AiChatMessageBubble(wm.messages.reversed.toList()[i]),
                    ),
            ),
          ],
          AiChatInputField(wm: wm),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, AiChatScreenWidgetModel wm) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AiChatStrings.welcomeTitle(context),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AiChatStrings.welcomeSubtitle(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (!wm.hasModelManager) ...[
              Text(
                AiChatStrings.noDownloadedModels(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => wm.showDownloadDialog(context),
                icon: const Icon(Icons.download),
                label: Text(AiChatStrings.downloadModelButton(context)),
              ),
            ] else ...[
              Text(
                AiChatStrings.selectModelForWork(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => wm.showModelSelector(context),
                icon: const Icon(Icons.tune),
                label: Text(AiChatStrings.selectModelAction(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }

}