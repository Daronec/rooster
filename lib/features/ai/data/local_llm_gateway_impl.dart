import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:rooster/features/ai/data/llm_native_bindings.dart';
import 'package:rooster/features/ai/data/llm_library_loader.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

/// Реализация LLM через llama.cpp FFI.
final class LocalLLMGatewayImpl implements ILocalLLMGateway {
  LlmNativeBindings? _bindings;
  ffi.Pointer<ffi.Void>? _handle;
  String? _modelInfo;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get modelInfo => _modelInfo;

  @override
  Future<void> initialize(String modelPath) async {
    if (_isInitialized) {
      return;
    }

    try {
      final bindings = LlmNativeBindings(LlmLibraryLoader.load());
      final handle = await bindings.init(modelPath);
      
      if (handle == null || handle.address == 0) {
        debugPrint('[LocalLLMGateway] Native llm_init returned null');
        debugPrint('[LocalLLMGateway] Model path: $modelPath');
        
        // Check if file exists and is readable
        final file = io.File(modelPath);
        if (!await file.exists()) {
          throw Exception('Model file not found: $modelPath');
        }
        final fileSize = await file.length();
        debugPrint('[LocalLLMGateway] File size: $fileSize bytes');
        
        throw Exception(
          'Failed to load model. Native library may not be compiled or model format unsupported. '
          'File exists: ${await file.exists()}, size: $fileSize bytes',
        );
      }

      _bindings = bindings;
      _handle = handle;
      _modelInfo = bindings.getInfo(handle);
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('[LocalLLMGateway] Initialization error: $e');
      debugPrint('[LocalLLMGateway] Stack: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<String?> generate({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    if (!_isInitialized || _handle == null) {
      throw StateError('LLM not initialized. Call initialize() first.');
    }

    try {
      final result = await _bindings!.generate(
        _handle!,
        prompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
      return result;
    } catch (e) {
      throw Exception('LLM generation error: $e');
    }
  }

  @override
  void dispose() {
    if (_handle != null && _handle!.address != 0) {
      _bindings?.dispose(_handle!);
      _handle = null;
      _bindings = null;
      _isInitialized = false;
    }
  }
}
