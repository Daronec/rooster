import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/ai/data/llm_model_manager_impl.dart';
import 'package:rooster/features/ai/data/llm_model_storage_service.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';
import 'package:rooster/features/app/di/app_scope.dart';

/// Состояние чата.
enum AiChatState {
  idle,
  loading,
  sending,
}

/// Представление сообщения для UI.
final class AiChatMessageEntity {
  const AiChatMessageEntity({required this.role, required this.text});

  final String role;
  final String text;
}

/// Модель экрана AI-чата: бизнес-логика и состояние.
final class AiChatScreenModel extends ElementaryModel {
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
  final ValueNotifier<List<LlmModelConfig>> downloadedModelsNotifier =
      ValueNotifier<List<LlmModelConfig>>([]);
  final ValueNotifier<LlmModelConfig?> selectedModelNotifier =
      ValueNotifier<LlmModelConfig?>(null);
  final ValueNotifier<AiChatState> stateNotifier =
      ValueNotifier<AiChatState>(AiChatState.idle);
  final ValueNotifier<List<AiChatMessageEntity>> messagesNotifier =
      ValueNotifier<List<AiChatMessageEntity>>([]);
  final ValueNotifier<String?> lastErrorNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<LlmModelManager?> modelManagerNotifier =
      ValueNotifier<LlmModelManager?>(null);
  final ValueNotifier<double> downloadProgressNotifier =
      ValueNotifier<double>(0.0);

  // Получение данных для UI
  List<LlmModelConfig> get downloadedModels => _downloadedModels;
  LlmModelConfig? get selectedModel => _selectedModel;
  List<AiChatMessageEntity> get messages => List.unmodifiable(_messages);
  AiChatState get state => _state;
  String? get lastError => _lastError;
  LlmModelManager? get modelManager => _modelManager;
  bool get isModelReady => _modelManager?.isReady ?? false;
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

  /// Загрузка выбранной модели.
  Future<void> _loadModel(LlmModelConfig model) async {
    if (_state == AiChatState.loading) return;

    _state = AiChatState.loading;
    stateNotifier.value = _state;

    try {
      _modelManager = LlmModelManager(selectedModel: model);
      modelManagerNotifier.value = _modelManager;
      final result = await _modelManager!.initialize();

      if (result.success) {
        _state = AiChatState.idle;
        _lastError = null;
      } else {
        _state = AiChatState.idle;
        _lastError = result.errorMessage ?? 'Неизвестная ошибка';
      }
    } on Exception catch (e, stackTrace) {
      _state = AiChatState.idle;
      _lastError = _formatNativeError(e);
      handleError(e, stackTrace: stackTrace);
    } finally {
      stateNotifier.value = _state;
      lastErrorNotifier.value = _lastError;
    }
  }

  /// Форматирование ошибки native библиотеки.
  String _formatNativeError(Exception e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('native') ||
        errorStr.contains('llm_bridge') ||
        errorStr.contains('ffi')) {
      return 'Native library error: LLM bridge not compiled or incompatible. '
          'Check if llama.cpp submodule is initialized and built.';
    }
    if (errorStr.contains('gguf') || errorStr.contains('model')) {
      return 'Model file format error. Try re-downloading the model.';
    }
    return e.toString();
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
    return '''Ты — полезный ассистент для управления задачами.
Ответь кратко и по делу.

Пользователь: $userText
Твой ответ:''';
  }
}
