import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/ai/data/llm_model_manager_impl.dart';
import 'package:rooster/features/ai/data/llm_model_storage_service.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// Состояние чата.
enum AiChatState {
  /// Ожидание действия пользователя.
  idle,

  /// Загрузка или инициализация модели.
  loading,

  /// Отправка сообщения и ожидание ответа.
  sending,
}

/// Представление сообщения для UI.
final class AiChatMessageEntity {
  /// Создаёт сущность сообщения.
  const AiChatMessageEntity({required this.role, required this.text});

  /// Роль сообщения ("user" или "assistant").
  final String role;

  /// Текст сообщения.
  final String text;
}

/// Модель экрана AI-чата: бизнес-логика и состояние.
final class AiChatScreenModel extends ElementaryModel {
  /// Создаёт модель экрана.
  AiChatScreenModel({
    required IAppScope appScope,
  }) : _appScope = appScope;

  final IAppScope _appScope;

  // Состояние модели
  LlmModelManager? _modelManager;
  LlmModelConfig? _selectedModel;
  List<LlmModelConfig> _downloadedModels = [];
  AiChatState _state = AiChatState.idle;
  String? _lastError;

  // Сообщения
  final List<AiChatMessageEntity> _messages = [];

  // Подписки
  StreamSubscription<Object?>? _subscription;

  // Notifiers для UI
  /// Уведомления о списке скачанных моделей.
  final ValueNotifier<List<LlmModelConfig>> downloadedModelsNotifier =
      ValueNotifier<List<LlmModelConfig>>([]);

  /// Уведомления о выбранной модели.
  final ValueNotifier<LlmModelConfig?> selectedModelNotifier =
      ValueNotifier<LlmModelConfig?>(null);

  /// Уведомления о состоянии чата.
  final ValueNotifier<AiChatState> stateNotifier = ValueNotifier<AiChatState>(
    AiChatState.idle,
  );

  /// Уведомления о сообщениях чата.
  final ValueNotifier<List<AiChatMessageEntity>> messagesNotifier =
      ValueNotifier<List<AiChatMessageEntity>>([]);

  /// Уведомления о последней ошибке.
  final ValueNotifier<String?> lastErrorNotifier = ValueNotifier<String?>(null);

  /// Уведомления о менеджере модели.
  final ValueNotifier<LlmModelManager?> modelManagerNotifier =
      ValueNotifier<LlmModelManager?>(null);

  /// Уведомления о прогрессе скачивания.
  final ValueNotifier<double> downloadProgressNotifier = ValueNotifier<double>(
    0,
  );

  // Получение данных для UI
  /// Список скачанных моделей.
  List<LlmModelConfig> get downloadedModels => _downloadedModels;

  /// Выбранная модель.
  LlmModelConfig? get selectedModel => _selectedModel;

  /// Список сообщений чата.
  List<AiChatMessageEntity> get messages => List.unmodifiable(_messages);

  /// Текущее состояние чата.
  AiChatState get state => _state;

  /// Последняя ошибка.
  String? get lastError => _lastError;

  /// Менеджер модели.
  LlmModelManager? get modelManager => _modelManager;

  /// Готова ли модель к использованию.
  bool get isModelReady => _modelManager?.isReady ?? false;

  /// Прогресс скачивания (0.0 - 1.0).
  double get downloadProgress => downloadProgressNotifier.value;

  @override
  void init() {
    super.init();
    _loadDownloadedModels();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _modelManager?.dispose();
    downloadedModelsNotifier.dispose();
    selectedModelNotifier.dispose();
    stateNotifier.dispose();
    messagesNotifier.dispose();
    lastErrorNotifier.dispose();
    modelManagerNotifier.dispose();
    super.dispose();
  }

  /// Загрузка списка скачанных моделей.
  Future<void> _loadDownloadedModels() async {
    try {
      _downloadedModels = await LlmModelStorageService.getDownloadedModels();
      downloadedModelsNotifier.value = _downloadedModels;
      // Не загружаем модель автоматически — пользователь выбирает сам
    } on Exception catch (e, stackTrace) {
      handleError(e, stackTrace: stackTrace);
    }
  }

  /// Скачать и загрузить модель.
  Future<void> downloadAndLoadModel(LlmModelConfig model) async {
    _state = AiChatState.loading;
    stateNotifier.value = _state;
    downloadProgressNotifier.value = 0.0;

    try {
      _modelManager = LlmModelManager(selectedModel: model);
      modelManagerNotifier.value = _modelManager;
      final result = await _modelManager!.initialize(
        forceDownload: true,
        onDownloadProgress: (progress) {
          downloadProgressNotifier.value = progress;
        },
      );

      if (result.success) {
        _selectedModel = model;
        selectedModelNotifier.value = _selectedModel;
        _state = AiChatState.idle;
        _lastError = null;
        await _loadDownloadedModels();
      } else {
        _state = AiChatState.idle;
        _lastError = result.errorMessage ?? 'Неизвестная ошибка';
      }
    } on Exception catch (e, stackTrace) {
      _state = AiChatState.idle;
      _lastError = '$e';
      handleError(e, stackTrace: stackTrace);
    } finally {
      stateNotifier.value = _state;
      lastErrorNotifier.value = _lastError;
    }
  }

  /// Отправка сообщения.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _state == AiChatState.sending) return;

    _messages.add(const AiChatMessageEntity(role: 'user', text: ''));
    _messages.removeLast();
    _messages.add(AiChatMessageEntity(role: 'user', text: trimmed));
    messagesNotifier.value = List.unmodifiable(_messages);
    _state = AiChatState.sending;
    stateNotifier.value = _state;

    try {
      if (isModelReady && _modelManager != null) {
        final prompt = _buildPrompt(trimmed);
        final response = await _modelManager!.generate(prompt: prompt);
        _messages.add(
          AiChatMessageEntity(
            role: 'assistant',
            text: response ?? 'Произошла ошибка при генерации ответа.',
          ),
        );
      } else if (_lastError != null) {
        _messages.add(
          const AiChatMessageEntity(
            role: 'assistant',
            text: 'Ошибка загрузки модели. Выберите модель в настройках.',
          ),
        );
      } else {
        final llm = _appScope.localLLMGateway;
        if (llm == null || !llm.isInitialized) {
          _messages.add(
            const AiChatMessageEntity(
              role: 'assistant',
              text: 'Модель LLM не загружена. Выберите модель в настройках.',
            ),
          );
        } else {
          final prompt = _buildPrompt(trimmed);
          final response = await llm.generate(prompt: prompt);
          _messages.add(
            AiChatMessageEntity(
              role: 'assistant',
              text: response ?? 'Произошла ошибка при генерации ответа.',
            ),
          );
        }
      }
    } on Exception catch (e, stackTrace) {
      _messages.add(
        AiChatMessageEntity(role: 'assistant', text: 'Ошибка: $e'),
      );
      handleError(e, stackTrace: stackTrace);
    } finally {
      messagesNotifier.value = List.unmodifiable(_messages);
      _state = AiChatState.idle;
      stateNotifier.value = _state;
    }
  }

  /// Выбор модели.
  void selectModel(LlmModelConfig model) {
    _selectedModel = model;
    selectedModelNotifier.value = _selectedModel;
  }

  /// Построение промпта.
  String _buildPrompt(String userText) {
    return '''
Ты — полезный ассистент для управления задачами.
Ответь кратко и по делу.

Пользователь: $userText
Твой ответ:''';
  }
}
