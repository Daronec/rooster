import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:uuid/uuid.dart';

/// Заглушка: на вебе загрузка файла с диска не ставится в очередь.
Future<void> enqueueTaskImageUploadIfNeeded({
  required TaskEntity task,
  required ISyncQueue syncQueue,
  required SyncManagerRef syncManagerRef,
  required Uuid uuid,
}) async {}
