import 'package:flutter/material.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_model.dart';
import 'package:rooster/features/ai/presentation/screens/ai_chat/ai_chat_screen.dart';
import 'package:rooster/features/ai/presentation/strings/ai_chat_strings.dart';

/// WidgetModel экрана AI-чата: UI-логика и взаимодействие с экраном.
class AiChatScreenWidgetModel extends BaseWidgetModel<AiChatScreen, AiChatScreenModel> {
  AiChatScreenWidgetModel(
    super.model, {
    required super.snackController,
  });

  final TextEditingController _controller = TextEditingController();

  /// Контроллер поля ввода.
  TextEditingController get controller => _controller;

  // Геттеры для UI (screen не должен обращаться к model напрямую)

  /// Состояние чата.
  AiChatState get state => model.state;

  /// Есть ли загруженная модель.
  bool get hasModelManager => model.modelManager != null;

  /// Готова ли модель к использованию.
  bool get isModelReady => model.isModelReady;

  /// Имя выбранной модели.
  String? get selectedModelName => model.selectedModel?.name;

  /// Список скачанных моделей.
  List<LlmModelConfig> get downloadedModels => model.downloadedModels;

  /// Сообщения чата.
  List<AiChatMessageEntity> get messages => model.messages;

  /// Последняя ошибка.
  String? get lastError => model.lastError;

  /// Прогресс скачивания (0.0 - 1.0).
  double get downloadProgress => model.downloadProgress;

  /// Скачивается ли модель в данный момент.
  bool get isDownloading =>
      model.state == AiChatState.loading && model.downloadProgress > 0;

  /// Показать диалог выбора модели.
  void showModelSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _ModelSelectorBottomSheet(
        downloadedModels: model.downloadedModels,
        availableModels: LlmModelConfig.availableModels,
        selectedModel: model.selectedModel,
        onModelSelected: (LlmModelConfig config) {
          model.selectModel(config);
          Navigator.pop(context);
          model.downloadAndLoadModel(config);
        },
        isModelReady: model.isModelReady,
        lastError: model.lastError,
      ),
    );
  }

  /// Показать диалог скачивания моделей (для случая когда нет скачанных).
  void showDownloadDialog(BuildContext context) {
    showModelSelector(context);
  }

  /// Отправить сообщение.
  Future<void> sendMessage(BuildContext context) async {
    final text = _controller.text;
    await model.sendMessage(text);
    if (context.mounted) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Bottom sheet для выбора модели.
class _ModelSelectorBottomSheet extends StatefulWidget {
  const _ModelSelectorBottomSheet({
    required this.downloadedModels,
    required this.availableModels,
    required this.selectedModel,
    required this.onModelSelected,
    required this.isModelReady,
    required this.lastError,
  });

  final List<LlmModelConfig> downloadedModels;
  final List<LlmModelConfig> availableModels;
  final LlmModelConfig? selectedModel;
  final void Function(LlmModelConfig) onModelSelected;
  final bool isModelReady;
  final String? lastError;

  @override
  State<_ModelSelectorBottomSheet> createState() => _ModelSelectorBottomSheetState();
}

class _ModelSelectorBottomSheetState extends State<_ModelSelectorBottomSheet> {
  /// Проверка: скачана ли модель.
  bool _isDownloaded(LlmModelConfig model) {
    return widget.downloadedModels.any(
      (d) => d.fileName.toLowerCase() == model.fileName.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            AiChatStrings.selectModelTitle(context),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (widget.downloadedModels.isEmpty) ...[
            Text(
              AiChatStrings.noDownloadedModels(context),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.lastError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AiChatStrings.modelError(context, error: widget.lastError!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...widget.availableModels.map((model) {
            final downloaded = _isDownloaded(model);
            final isSelected = widget.selectedModel?.name == model.name;

            return ListTile(
              leading: downloaded
                  ? Icon(
                      isSelected && widget.isModelReady
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isSelected && widget.isModelReady
                          ? theme.colorScheme.primary
                          : null,
                    )
                  : const Icon(Icons.download_for_offline),
              title: Text(model.name),
              subtitle: Text(model.description),
              trailing: downloaded
                  ? null
                  : TextButton.icon(
                      onPressed: () {
                        widget.onModelSelected(model);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(AiChatStrings.downloadModelButton(context)),
                    ),
              selected: isSelected,
              onTap: downloaded
                  ? () {
                      widget.onModelSelected(model);
                      Navigator.pop(context);
                    }
                  : null,
            );
          }),
        ],
      ),
    ),
    );
  }
}
