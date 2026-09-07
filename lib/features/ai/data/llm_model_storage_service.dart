import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:rooster/features/ai/domain/models/llm_model_config.dart';

/// Service for managing downloaded LLM models.
final class LlmModelStorageService {
  /// Get the models directory path.
  static Future<String> getModelsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelsDir = io.Directory('${directory.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  /// Get the full path for a model file.
  static Future<String> getModelFilePath(String fileName) async {
    final modelsDir = await getModelsDirectory();
    return '$modelsDir/$fileName';
  }

  /// Check if a model file exists.
  static Future<bool> modelExists(String fileName) async {
    final path = await getModelFilePath(fileName);
    return io.File(path).exists();
  }

  /// Get list of downloaded models.
  static Future<List<LlmModelConfig>> getDownloadedModels() async {
    final modelsDir = await getModelsDirectory();
    final directory = io.Directory(modelsDir);
    
    if (!await directory.exists()) {
      return [];
    }

    final downloadedModels = <LlmModelConfig>[];
    
    await for (final entity in directory.list()) {
      if (entity is io.File && entity.path.endsWith('.gguf')) {
        final fileName = entity.path.split('/').last;
        
        // Find matching model config (case-insensitive)
        final matchingConfig = LlmModelConfig.availableModels.firstWhere(
          (config) => config.fileName.toLowerCase() == fileName.toLowerCase(),
          orElse: () => LlmModelConfig(
            name: fileName.replaceAll('.gguf', ''),
            description: 'Custom model',
            url: '',
            fileSize: 0,
            quantization: 'Unknown',
            fileName: fileName,
          ),
        );
        
        // Get file size
        final fileSize = await entity.length();
        
        downloadedModels.add(LlmModelConfig(
          name: matchingConfig.name,
          description: matchingConfig.description,
          url: matchingConfig.url,
          fileSize: fileSize,
          quantization: matchingConfig.quantization,
          fileName: fileName, // Use actual filename from disk
        ));
      }
    }
    
    return downloadedModels;
  }

  /// Get file size in human-readable format.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Delete a model file.
  static Future<bool> deleteModel(String fileName) async {
    final path = await getModelFilePath(fileName);
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }
}
