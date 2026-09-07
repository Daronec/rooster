import 'dart:async';

import 'package:rooster/features/ai/data/llm_model_downloader.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';

/// State of the LLM model lifecycle.
enum LlmModelState {
  /// Model has not been checked or downloaded yet.
  unknown,

  /// Model file exists and is ready to be loaded.
  ready,

  /// Model is currently being downloaded.
  downloading,

  /// Model is currently being loaded into memory.
  loading,

  /// Model is loaded and ready to use.
  loaded,

  /// Model download or loading failed.
  failed,
}

/// Result of model initialization.
final class LlmInitResult {
  /// Creates a new [LlmInitResult].
  const LlmInitResult({
    required this.success,
    this.modelPath,
    this.errorMessage,
    this.downloadProgress = 0.0,
  });

  /// Whether the initialization was successful.
  final bool success;

  /// Path to the model file (empty if failed).
  final String? modelPath;

  /// Error message if initialization failed.
  final String? errorMessage;

  /// Download progress (0.0 to 1.0), only relevant during download.
  final double downloadProgress;

  /// Creates a success result.
  factory LlmInitResult.success(String modelPath, {double downloadProgress = 0.0}) {
    return LlmInitResult(
      success: true,
      modelPath: modelPath,
      downloadProgress: downloadProgress,
    );
  }

  /// Creates a failure result.
  factory LlmInitResult.failure(String errorMessage, {double downloadProgress = 0.0}) {
    return LlmInitResult(
      success: false,
      errorMessage: errorMessage,
      downloadProgress: downloadProgress,
    );
  }
}

/// Callback for LLM state changes.
typedef LlmStateChangeCallback = void Function(LlmModelState state);

/// Callback for LLM progress updates.
typedef LlmProgressCallback = void Function(double progress);

/// Manages the LLM model download and initialization lifecycle.
///
/// This service handles:
/// - Checking if the model file exists locally
/// - Downloading the model from a remote URL
/// - Initializing the model with the native llama.cpp backend
/// - Reporting progress and state changes
abstract interface class ILlmModelManager {
  /// Current state of the LLM model.
  LlmModelState get state;

  /// Download progress (0.0 to 1.0), relevant during download phase.
  double get downloadProgress;

  /// Whether the model is ready to generate responses.
  bool get isReady;

  /// Error message if the last operation failed.
  String? get lastError;

  /// Initialize the LLM model.
  ///
  /// This method will:
  /// 1. Check if the model file exists locally
  /// 2. Download the model if it doesn't exist
  /// 3. Initialize the model with the native backend
  ///
  /// [forceDownload] - If true, downloads the model even if it exists locally.
  Future<LlmInitResult> initialize({bool forceDownload = false});

  /// Download the model file only (without initializing).
  Future<DownloadResult> downloadModelOnly({
    required LlmModelConfig model,
    DownloadProgressCallback? onProgress,
  });

  /// Reset the LLM state to unknown.
  void reset();

  /// Dispose resources and clean up.
  void dispose();

  /// Generate a response using the loaded model.
  ///
  /// [prompt] - The input prompt text.
  /// [maxTokens] - Maximum tokens to generate.
  /// [temperature] - Temperature for generation.
  ///
  /// Returns the generated response text, or null on error.
  Future<String?> generate({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.7,
  });
}
