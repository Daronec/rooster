import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

/// Use Case для категоризации задачи с помощью LLM.
final class CategorizeTaskUseCase {
  CategorizeTaskUseCase({required this.llmGateway});

  /// Gateway для доступа к локальной LLM.
  final ILocalLLMGateway? llmGateway;

  /// Определить категорию задачи по её описанию.
  ///
  /// Возвращает: 'work', 'personal', 'learning', 'health' или null в случае ошибки.
  Future<String?> call(String taskDescription) async {
    if (llmGateway == null || !llmGateway!.isInitialized) {
      return null;
    }

    try {
      final prompt = '''Ты — помощник по управлению задачами.
Определи категорию задачи на основе её описания.
Ответь одним словом: work, personal, learning или health.

Задача: $taskDescription

Категория:''';

      final response = await llmGateway!.generate(
        prompt: prompt,
        maxTokens: 15,
        temperature: 0.3,
      );

      if (response == null) {
        return null;
      }

      final normalized = response.toLowerCase().trim();
      if (normalized.contains('work')) return 'work';
      if (normalized.contains('personal')) return 'personal';
      if (normalized.contains('learn')) return 'learning';
      if (normalized.contains('health')) return 'health';
      return 'work';
    } catch (e) {
      return null;
    }
  }
}
