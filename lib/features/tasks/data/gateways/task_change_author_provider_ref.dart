import 'package:rooster/features/tasks/domain/gateways/i_task_change_author_provider.dart';

/// Поздняя привязка источника автора, потому что репозиторий задач создаётся до auth-сборки.
final class TaskChangeAuthorProviderRef implements ITaskChangeAuthorProvider {
  /// Текущий источник автора.
  ITaskChangeAuthorProvider? target;

  @override
  String? get currentAuthorName => target?.currentAuthorName;
}
