import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

/// Use Case для определения приоритета задачи с помощью LLM.
final class ClassifyTaskPriorityUseCase {
  ClassifyTaskPriorityUseCase({required this.llmGateway});

  /// Gateway для доступа к локальной LLM.
  final ILocalLLMGateway? llmGateway;

  /// Определить приоритет задачи по её описанию.
  ///
  /// Возвращает: 'high', 'medium', 'low' или null в случае ошибки.
  Future<String?> call(String taskDescription) async {
    if (llmGateway == null || !llmGateway!.isInitialized) {
      return null;
    }

    try {
      final prompt = '''Ты — помощник по управлению задачами.
Определи приоритет задачи на основе её описания.
Ответь одним словом: high, medium или low.

Задача: $taskDescription

Приоритет:''';

      final response = await llmGateway!.generate(
        prompt: prompt,
        maxTokens: 10,
        temperature: 0.3,
      );

      if (response == null) {
        return null;
      }

      final normalized = response.toLowerCase().trim();
      if (normalized.contains('high')) return 'high';
      if (normalized.contains('low')) return 'low';
      return 'medium';
    } catch (e) {
      return null;
    }
  }
}
