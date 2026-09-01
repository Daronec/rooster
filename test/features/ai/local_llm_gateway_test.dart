import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

// Mock реализация для тестирования
class MockLocalLLMGateway implements ILocalLLMGateway {
  bool _isInitialized = false;
  String? _modelInfo;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get modelInfo => _modelInfo;

  @override
  Future<void> initialize(String modelPath) async {
    _isInitialized = true;
    _modelInfo = 'Mock Model ($modelPath)';
  }

  @override
  Future<String?> generate({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    if (!_isInitialized) {
      throw StateError('LLM not initialized');
    }
    return 'Mock response to: $prompt';
  }

  @override
  void dispose() {
    _isInitialized = false;
    _modelInfo = null;
  }
}

void main() {
  group('LocalLLMGateway', () {
    test('isInitialized returns false initially', () {
      final gateway = MockLocalLLMGateway();
      expect(gateway.isInitialized, isFalse);
    });

    test('isInitialized returns true after init', () async {
      final gateway = MockLocalLLMGateway();
      await gateway.initialize('mock_model.gguf');
      expect(gateway.isInitialized, isTrue);
    });

    test('throws on generate before init', () async {
      final gateway = MockLocalLLMGateway();
      expect(
        () async => gateway.generate(prompt: 'test'),
        throwsA(isA<StateError>()),
      );
    });

    test('generate returns response after init', () async {
      final gateway = MockLocalLLMGateway();
      await gateway.initialize('mock_model.gguf');
      final response = await gateway.generate(prompt: 'Hello');
      expect(response, contains('Mock response'));
    });

    test('dispose resets state', () async {
      final gateway = MockLocalLLMGateway();
      await gateway.initialize('mock_model.gguf');
      expect(gateway.isInitialized, isTrue);
      
      gateway.dispose();
      expect(gateway.isInitialized, isFalse);
    });

    test('modelInfo returns info after init', () async {
      final gateway = MockLocalLLMGateway();
      expect(gateway.modelInfo, isNull);
      
      await gateway.initialize('mock_model.gguf');
      expect(gateway.modelInfo, isNotNull);
      expect(gateway.modelInfo, contains('Mock Model'));
    });
  });
}
