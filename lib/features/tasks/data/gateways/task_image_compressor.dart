import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as image_lib;

/// Результат сжатия изображения задачи.
final class TaskImageCompressionResult {
  /// Создаёт результат сжатия.
  const TaskImageCompressionResult({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  /// Сжатые байты изображения.
  final List<int> bytes;

  /// Расширение файла без точки.
  final String extension;

  /// MIME-тип изображения.
  final String contentType;
}

/// Сжатие изображений задач перед локальным сохранением и облачной загрузкой.
final class TaskImageCompressor {
  const TaskImageCompressor._();

  static const int _maxDimension = 1280;
  static const int _targetMaxBytes = 400 * 1024;
  static const int _minDimension = 720;
  static const int _minQuality = 45;
  static const int _maxQuality = 85;

  /// Сжать изображение в JPEG: длинная сторона до 1280px, целевой размер до 400 KB.
  static Future<TaskImageCompressionResult> compressToJpeg(
    Uint8List sourceBytes,
  ) {
    return Isolate.run(() => _compressToJpegSync(sourceBytes));
  }

  static TaskImageCompressionResult _compressToJpegSync(Uint8List sourceBytes) {
    final decodedImage = image_lib.decodeImage(sourceBytes);
    if (decodedImage == null) {
      throw const FormatException('Не удалось прочитать изображение задачи');
    }

    var targetDimension = _maxDimension;
    var resizedImage = _resizeToLongestSide(decodedImage, targetDimension);
    var encodedBytes = _encodeUnderTargetBytes(resizedImage);

    while (encodedBytes.length > _targetMaxBytes &&
        targetDimension > _minDimension) {
      targetDimension = math.max(
        _minDimension,
        (targetDimension * 0.85).round(),
      );
      resizedImage = _resizeToLongestSide(decodedImage, targetDimension);
      encodedBytes = _encodeUnderTargetBytes(resizedImage);
    }

    return TaskImageCompressionResult(
      bytes: encodedBytes,
      extension: 'jpg',
      contentType: 'image/jpeg',
    );
  }

  static image_lib.Image _resizeToLongestSide(
    image_lib.Image source,
    int maxDimension,
  ) {
    final longestSide = math.max(source.width, source.height);
    if (longestSide <= maxDimension) {
      return source;
    }
    if (source.width >= source.height) {
      return image_lib.copyResize(
        source,
        width: maxDimension,
        interpolation: image_lib.Interpolation.average,
      );
    }
    return image_lib.copyResize(
      source,
      height: maxDimension,
      interpolation: image_lib.Interpolation.average,
    );
  }

  static List<int> _encodeUnderTargetBytes(image_lib.Image image) {
    var lowQuality = _minQuality;
    var highQuality = _maxQuality;
    var bestUnderTarget = image_lib.encodeJpg(image, quality: _minQuality);
    var smallestOverTarget = bestUnderTarget;

    while (lowQuality <= highQuality) {
      final quality = ((lowQuality + highQuality) / 2).floor();
      final encodedBytes = image_lib.encodeJpg(image, quality: quality);
      if (encodedBytes.length <= _targetMaxBytes) {
        bestUnderTarget = encodedBytes;
        lowQuality = quality + 1;
      } else {
        smallestOverTarget = encodedBytes;
        highQuality = quality - 1;
      }
    }

    if (bestUnderTarget.length <= _targetMaxBytes) {
      return bestUnderTarget;
    }
    return smallestOverTarget;
  }
}
