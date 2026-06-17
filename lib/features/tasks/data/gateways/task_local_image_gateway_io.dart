import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:rooster/features/tasks/data/gateways/task_image_compressor.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_local_image_gateway.dart';

/// Копирование вложений задач в каталог документов приложения (Android / iOS / desktop).
final class TaskLocalImageGatewayIo implements ITaskLocalImageGateway {
  /// Создаёт шлюз копирования файлов на диск.
  const TaskLocalImageGatewayIo();

  @override
  Future<String> persistPickerFile(
    String sourcePath, {
    required String taskId,
  }) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final folder = Directory('${baseDir.path}/task_images');
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File('${folder.path}/${taskId}_$stamp.jpg');
    final sourceBytes = await File(sourcePath).readAsBytes();
    final compressionResult = await TaskImageCompressor.compressToJpeg(
      Uint8List.fromList(sourceBytes),
    );
    await dest.writeAsBytes(compressionResult.bytes, flush: true);
    return dest.path;
  }
}
