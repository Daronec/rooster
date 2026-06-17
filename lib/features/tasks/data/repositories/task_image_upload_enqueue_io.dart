import 'dart:io' show File;

import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:uuid/uuid.dart';

/// Ставит в очередь загрузку изображения задачи, если есть локальный файл.
Future<void> enqueueTaskImageUploadIfNeeded({
  required TaskEntity task,
  required ISyncQueue syncQueue,
  required SyncManagerRef syncManagerRef,
  required Uuid uuid,
}) async {
  var enqueuedAny = false;
  for (final image in task.imageAttachments) {
    if (image.localPath.isEmpty) {
      continue;
    }
    if (image.remoteUrl != null && image.remoteUrl!.isNotEmpty) {
      continue;
    }
    final file = File(image.localPath);
    if (!file.existsSync()) {
      continue;
    }
    await syncQueue.enqueue(
      SyncOperation(
        id: uuid.v4(),
        type: SyncOperationType.uploadTaskImage,
        payload: {'taskId': task.id, 'localPath': image.localPath},
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    enqueuedAny = true;
  }
  if (enqueuedAny) {
    await syncManagerRef.scheduleSync();
  }
}
