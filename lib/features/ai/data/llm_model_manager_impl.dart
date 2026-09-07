import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rooster/features/ai/data/llm_model_downloader.dart';
import 'package:rooster/features/ai/data/local_llm_gateway_impl.dart';
import 'package:rooster/features/ai/domain/gateways/i_llm_model_manager.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';

/// Implementation of [ILlmModelManager] that handles model download and initialization.
final class LlmModelManager implements ILlmModelManager {
  LlmModelManager({
    required this.selectedModel,
  });

  /// Currently selected model configuration.
  final LlmModelConfig selectedModel;

  @override
  LlmModelState state = LlmModelState.unknown;

  @override
  double downloadProgress = 0;

  @override
  String? lastError;

  ILocalLLMGateway? _gateway;

  @override
  bool get isReady =>
      state == LlmModelState.loaded && (_gateway?.isInitialized ?? false);

  @override
  Future<LlmInitResult> initialize({
    bool forceDownload = false,
    void Function(double)? onDownloadProgress,
  }) async {
    debugPrint(
      '[LlmModelManager] Starting initialization for: ${selectedModel.name}',
    );
    debugPrint('[LlmModelManager] Model URL: ${selectedModel.url}');
    debugPrint('[LlmModelManager] Force download: $forceDownload');

    try {
      // If already loaded, return success
      if (isReady) {
        debugPrint('[LlmModelManager] Model already loaded, returning success');
        return const LlmInitResult(success: true);
      }

      // Check if model file exists
      debugPrint('[LlmModelManager] Checking if model exists locally...');
      final modelExists = await LlmModelDownloader.modelExists(
        modelName: selectedModel.fileName,
      );
      debugPrint('[LlmModelManager] Model exists: $modelExists');

      if (!modelExists || forceDownload) {
        // Download the model
        debugPrint('[LlmModelManager] Starting model download...');
        state = LlmModelState.downloading;
        downloadProgress = 0.0;

        final downloadResult = await LlmModelDownloader.downloadModel(
          modelUrl: selectedModel.url,
          modelName: selectedModel.fileName,
          forceRedownload: forceDownload,
          onProgress: (progress) {
            debugPrint(
              '[LlmModelManager] Download progress: ${(progress * 100).toInt()}%',
            );
            downloadProgress = progress;
            onDownloadProgress?.call(progress);
          },
        );

        debugPrint(
          '[LlmModelManager] Download completed. Success: ${downloadResult.success}',
        );

        if (!downloadResult.success) {
          state = LlmModelState.failed;
          lastError = downloadResult.errorMessage;
          debugPrint(
            '[LlmModelManager] Download failed: ${downloadResult.errorMessage}',
          );
          return LlmInitResult.failure(
            downloadResult.errorMessage ?? 'Download failed',
            downloadProgress: downloadProgress,
          );
        }

        downloadProgress = 1.0;
        debugPrint(
          '[LlmModelManager] Download successful, file path: ${downloadResult.filePath}',
        );
      }

      // Get model file path
      debugPrint('[LlmModelManager] Getting model file path...');
      final modelPath = await LlmModelDownloader.getModelFilePath(
        modelName: selectedModel.fileName,
      );
      debugPrint('[LlmModelManager] Model path: $modelPath');

      // Initialize the LLM gateway
      debugPrint('[LlmModelManager] Loading model into memory...');
      state = LlmModelState.loading;

      _gateway = LocalLLMGatewayImpl();
      debugPrint('[LlmModelManager] Creating LocalLLMGatewayImpl...');

      await _gateway!.initialize(modelPath);
      debugPrint('[LlmModelManager] initialize() completed');

      if (_gateway!.isInitialized) {
        debugPrint('[LlmModelManager] Model loaded successfully!');
        state = LlmModelState.loaded;
        lastError = null;
        return LlmInitResult(success: true, modelPath: modelPath);
      } else {
        debugPrint(
          '[LlmModelManager] Model failed to initialize (isInitialized=false)',
        );
        state = LlmModelState.failed;
        lastError = 'Model failed to load into memory';
        return LlmInitResult.failure('Model failed to load into memory');
      }
    } on Exception catch (e, stackTrace) {
      debugPrint('[LlmModelManager] Exception during initialization: $e');
      debugPrint('[LlmModelManager] Stack trace: $stackTrace');
      state = LlmModelState.failed;
      lastError = 'Initialization error: $e';
      return LlmInitResult.failure('Initialization error: $e');
    } catch (e, stackTrace) {
      debugPrint('[LlmModelManager] Unexpected error: $e');
      debugPrint('[LlmModelManager] Stack trace: $stackTrace');
      state = LlmModelState.failed;
      lastError = 'Unexpected error: $e';
      return LlmInitResult.failure('Unexpected error: $e');
    }
  }

  @override
  Future<DownloadResult> downloadModelOnly({
    required LlmModelConfig model,
    DownloadProgressCallback? onProgress,
  }) async {
    debugPrint('[LlmModelManager] Downloading model: ${model.name}');
    state = LlmModelState.downloading;

    final result = await LlmModelDownloader.downloadModel(
      modelUrl: model.url,
      modelName: model.fileName,
      onProgress: (double progress) {
        onProgress?.call(progress);
      },
    );

    if (result.success) {
      state = LlmModelState.ready;
      downloadProgress = 1.0;
    } else {
      state = LlmModelState.failed;
      lastError = result.errorMessage;
    }

    return result;
  }

  @override
  void reset() {
    _gateway?.dispose();
    _gateway = null;
    state = LlmModelState.unknown;
    downloadProgress = 0.0;
    lastError = null;
  }

  @override
  void dispose() {
    _gateway?.dispose();
    _gateway = null;
    state = LlmModelState.unknown;
  }

  @override
  Future<String?> generate({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    if (!isReady || _gateway == null) {
      throw StateError('Model is not ready. Call initialize() first.');
    }

    try {
      return await _gateway!.generate(
        prompt: prompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
    } on Exception catch (e) {
      throw Exception('Generation error: $e');
    }
  }
}
