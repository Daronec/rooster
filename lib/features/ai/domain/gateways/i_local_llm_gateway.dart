import 'dart:async';

/// Контракт для локальной LLM-модели.
abstract interface class ILocalLLMGateway {
  /// Инициализировать модель из файла.
  Future<void> initialize(String modelPath);

  /// Сгенерировать ответ на prompt.
  Future<String?> generate({
    required String prompt,
    int maxTokens,
    double temperature,
  });

  /// Проверить, инициализирована ли модель.
  bool get isInitialized;

  /// Информация о модели.
  String? get modelInfo;

  /// Освободить ресурсы.
  void dispose();
}
