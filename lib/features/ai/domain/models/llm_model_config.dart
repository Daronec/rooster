/// Конфигурация доступных LLM моделей.
final class LlmModelConfig {
  const LlmModelConfig({
    required this.name,
    required this.description,
    required this.url,
    required this.fileSize,
    required this.quantization,
    this.isDefault = false,
    String? fileName,
  }) : _fileName = fileName;

  /// Название модели.
  final String name;

  /// Описание модели.
  final String description;

  /// URL для скачивания.
  final String url;

  /// Размер файла в байтах.
  final int fileSize;

  /// Квантование (Q4_K_M, Q5_K_M, и т.д.).
  final String quantization;

  /// Является ли модель по умолчанию.
  final bool isDefault;

  /// Имя файла модели.
  final String? _fileName;

  /// Получение имени файла.
  String get fileName => _fileName ?? url.split('/').last;

  /// Список доступных моделей.
  static const List<LlmModelConfig> availableModels = [
    LlmModelConfig(
      name: 'Llama 3.2 1B',
      description: 'Лёгкая модель, ~0.8 ГБ, RAM ~1.5 ГБ',
      url:
          'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
      fileSize: 800 * 1024 * 1024,
      quantization: 'Q4_K_M',
      isDefault: true,
      fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    ),
    LlmModelConfig(
      name: 'Llama 3.2 3B',
      description: 'Средняя модель, ~2 ГБ, RAM ~3 ГБ',
      url:
          'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
      fileSize: 2 * 1024 * 1024 * 1024,
      quantization: 'Q4_K_M',
      fileName: 'Llama-3.2-3B-Instruct-Q4_K_M.gguf',
    ),
    LlmModelConfig(
      name: 'Llama 3.2 1B (Q5)',
      description: 'Высокое качество, ~1 ГБ, RAM ~2 ГБ',
      url:
          'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q5_K_M.gguf',
      fileSize: 1 * 1024 * 1024 * 1024,
      quantization: 'Q5_K_M',
      fileName: 'Llama-3.2-1B-Instruct-Q5_K_M.gguf',
    ),
  ];

  /// Модель по умолчанию.
  static LlmModelConfig get defaultModel =>
      availableModels.firstWhere(
        (m) => m.isDefault,
        orElse: () => availableModels.first,
      );
}
