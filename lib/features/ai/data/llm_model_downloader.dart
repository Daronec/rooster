import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Callback for download progress updates (0.0 to 1.0).
typedef DownloadProgressCallback = void Function(double progress);

/// Result of a model download operation.
final class DownloadResult {
  /// Creates a new [DownloadResult].
  const DownloadResult({
    required this.success,
    required this.filePath,
    this.progress = 0.0,
    this.errorMessage,
  });

  /// Whether the download was successful.
  final bool success;

  /// Path to the downloaded file (empty if failed).
  final String filePath;

  /// Download progress (0.0 to 1.0).
  final double progress;

  /// Error message if download failed.
  final String? errorMessage;

  /// Creates a success result.
  factory DownloadResult.success(String filePath, {double progress = 1.0}) {
    return DownloadResult(
      success: true,
      filePath: filePath,
      progress: progress,
    );
  }

  /// Creates a failure result.
  factory DownloadResult.failure(String errorMessage, {double progress = 0.0}) {
    return DownloadResult(
      success: false,
      filePath: '',
      progress: progress,
      errorMessage: errorMessage,
    );
  }
}

/// Service for downloading LLM model files.
final class LlmModelDownloader {
  /// Downloads the LLM model from the given URL to the app's documents directory.
  ///
  /// [modelUrl] - URL to download the model from.
  /// [modelName] - Name for the downloaded model file (default: llama-model.gguf).
  /// [onProgress] - Optional callback for progress updates (0.0 to 1.0).
  /// [forceRedownload] - If true, downloads even if model already exists.
  ///
  /// Returns a [DownloadResult] with success/failure status and file path.
  static Future<DownloadResult> downloadModel({
    required String modelUrl,
    String modelName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
    DownloadProgressCallback? onProgress,
    bool forceRedownload = false,
  }) async {
    debugPrint('[LlmModelDownloader] Starting download...');
    debugPrint('[LlmModelDownloader] URL: $modelUrl');
    debugPrint('[LlmModelDownloader] Model name: $modelName');
    debugPrint('[LlmModelDownloader] Force redownload: $forceRedownload');

    try {
      // Check if model already exists
      debugPrint('[LlmModelDownloader] Checking for existing model...');
      final existingPath = await getModelFilePath(modelName: modelName);
      debugPrint('[LlmModelDownloader] Existing path: $existingPath');
      
      final fileExists = io.File(existingPath).existsSync();
      debugPrint('[LlmModelDownloader] File exists: $fileExists');
      
      if (!forceRedownload && fileExists) {
        debugPrint('[LlmModelDownloader] Model already exists, returning cached path');
        return DownloadResult.success(existingPath);
      }

      // Get documents directory
      debugPrint('[LlmModelDownloader] Getting application documents directory...');
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('[LlmModelDownloader] Documents directory: ${directory.path}');
      
      final modelDir = io.Directory('${directory.path}/models');

      // Create models directory if it doesn't exist
      if (!modelDir.existsSync()) {
        debugPrint('[LlmModelDownloader] Creating models directory...');
        await modelDir.create(recursive: true);
      }

      final modelPath = '${modelDir.path}/$modelName';
      debugPrint('[LlmModelDownloader] Model path: $modelPath');
      
      final file = io.File(modelPath);
      final fileStream = file.openWrite();

      // Download the model
      debugPrint('[LlmModelDownloader] Sending HTTP request...');
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await request.send();
      debugPrint('[LlmModelDownloader] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        await fileStream.close();
        await file.delete();
        debugPrint('[LlmModelDownloader] Download failed with status ${response.statusCode}');
        return DownloadResult.failure(
          'Download failed with status ${response.statusCode}',
        );
      }

      // Get total size for progress calculation
      final bytesExpected = response.contentLength ?? -1;
      debugPrint('[LlmModelDownloader] Expected size: $bytesExpected bytes');
      
      var bytesReceived = 0;

      // Stream the response body to file
      debugPrint('[LlmModelDownloader] Streaming response to file...');
      await response.stream.forEach((chunk) {
        fileStream.write(chunk);
        bytesReceived += chunk.length;

        if (bytesExpected > 0) {
          final progress = bytesReceived / bytesExpected;
          onProgress?.call(progress);
        } else {
          // If total size is unknown, provide incremental progress updates
          onProgress?.call(0.5); // Partial progress when size is unknown
        }
      });

      await fileStream.close();
      debugPrint('[LlmModelDownloader] Download completed. Bytes received: $bytesReceived');

      // Verify file was created
      if (!file.existsSync()) {
        debugPrint('[LlmModelDownloader] ERROR: Model file was not created');
        return DownloadResult.failure('Model file was not created');
      }

      // Verify file size
      final actualSize = await file.length();
      debugPrint('[LlmModelDownloader] Actual file size: $actualSize bytes');
      
      if (bytesExpected > 0 && actualSize < bytesExpected) {
        debugPrint('[LlmModelDownloader] ERROR: Download incomplete. Expected: $bytesExpected, Got: $actualSize');
        await file.delete();
        return DownloadResult.failure(
          'Download incomplete. Expected $bytesExpected bytes, got $actualSize bytes. Check your internet connection.',
        );
      }

      // Verify GGUF magic number
      debugPrint('[LlmModelDownloader] Verifying GGUF magic number...');
      final fileHandle = file.openSync(mode: FileMode.read);
      final magicBytes = fileHandle.readSync(4);
      fileHandle.closeSync();
      
      final magicString = String.fromCharCodes(magicBytes);
      debugPrint('[LlmModelDownloader] Magic: $magicString');
      
      if (magicString != 'GGUF') {
        debugPrint('[LlmModelDownloader] ERROR: Invalid GGUF magic number: $magicString');
        await file.delete();
        return DownloadResult.failure(
          'Invalid file format. Expected GGUF file, got: $magicString. The downloaded file may be corrupted.',
        );
      }
      
      debugPrint('[LlmModelDownloader] GGUF validation passed');

      final fileSize = await file.length();
      debugPrint('[LlmModelDownloader] File size: $fileSize bytes');
      debugPrint('[LlmModelDownloader] Download successful!');

      return DownloadResult.success(modelPath);
    } on io.IOException catch (e, stackTrace) {
      debugPrint('[LlmModelDownloader] IOException: $e');
      debugPrint('[LlmModelDownloader] Stack trace: $stackTrace');
      return DownloadResult.failure('Network error: $e');
    } on http.ClientException catch (e, stackTrace) {
      debugPrint('[LlmModelDownloader] ClientException: $e');
      debugPrint('[LlmModelDownloader] Stack trace: $stackTrace');
      return DownloadResult.failure('HTTP error: ${e.message}');
    } on Exception catch (e, stackTrace) {
      debugPrint('[LlmModelDownloader] Exception: $e');
      debugPrint('[LlmModelDownloader] Stack trace: $stackTrace');
      return DownloadResult.failure('Download failed: $e');
    } catch (e, stackTrace) {
      debugPrint('[LlmModelDownloader] Unexpected error: $e');
      debugPrint('[LlmModelDownloader] Stack trace: $stackTrace');
      return DownloadResult.failure('Unexpected error: $e');
    }
  }

  /// Gets the file path where the model should be stored.
  ///
  /// [modelName] - Name of the model file.
  ///
  /// Returns the full path to the model file.
  static Future<String> getModelFilePath({
    String modelName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/models/$modelName';
  }

  /// Checks if the model file exists.
  ///
  /// [modelName] - Name of the model file.
  ///
  /// Returns true if the model file exists.
  static Future<bool> modelExists({
    String modelName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
  }) async {
    final path = await getModelFilePath(modelName: modelName);
    return io.File(path).existsSync();
  }

  /// Gets the size of the model file in bytes.
  ///
  /// [modelName] - Name of the model file.
  ///
  /// Returns the file size in bytes, or null if the file doesn't exist.
  static Future<int?> getModelFileSize({
    String modelName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
  }) async {
    final path = await getModelFilePath(modelName: modelName);
    final file = io.File(path);
    if (file.existsSync()) {
      return file.length();
    }
    return null;
  }

  /// Deletes the model file.
  ///
  /// [modelName] - Name of the model file.
  ///
  /// Returns true if the file was deleted or didn't exist.
  static Future<bool> deleteModel({
    String modelName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
  }) async {
    final path = await getModelFilePath(modelName: modelName);
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
    }
    return true;
  }
}
