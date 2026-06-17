import 'package:rooster/features/tasks/domain/gateways/i_task_local_image_gateway.dart';

/// Реализация без `dart:io` (веб): файл не копируется в постоянный каталог.
final class TaskLocalImageGatewayStub implements ITaskLocalImageGateway {
  /// Создаёт заглушку для платформ без файловой системы.
  const TaskLocalImageGatewayStub();

  @override
  Future<String> persistPickerFile(
    String sourcePath, {
    required String taskId,
  }) async {
    return sourcePath;
  }
}
