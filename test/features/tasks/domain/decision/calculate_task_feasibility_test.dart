import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/default_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

void main() {
  final useCase = CalculateTaskFeasibility(
    policy: const DefaultFeasibilityScoringPolicy(),
  );

  test('интеграция: смена completed у предшественника меняет статус на ready', () {
    final predecessorPending = _task(
      id: 'p',
      status: TaskStatusEntity.pending,
      title: 'Pred',
    );
    final successor = _task(
      id: 's',
      status: TaskStatusEntity.pending,
      title: 'Succ',
      deps: const ['p'],
    );
    final mapPending = <String, TaskEntity>{
      'p': predecessorPending,
      's': successor,
    };

    final blocked = useCase.execute(
      task: successor,
      tasksById: mapPending,
      stockItems: const [],
      budget: const BudgetPeriodEntity(
        year: 2026,
        month: 1,
        amountLimit: 500,
      ),
    );
    expect(blocked.status, TaskFeasibilityStatusEntity.blockedDependencies);

    final predecessorDone =
        predecessorPending.copyWith(status: TaskStatusEntity.completed);
    final mapDone = <String, TaskEntity>{
      'p': predecessorDone,
      's': successor,
    };

    final ready = useCase.execute(
      task: successor,
      tasksById: mapDone,
      stockItems: const [],
      budget: const BudgetPeriodEntity(
        year: 2026,
        month: 1,
        amountLimit: 500,
      ),
    );
    expect(ready.status, TaskFeasibilityStatusEntity.ready);
    expect(ready.score, isNotNaN);
  });
}

TaskEntity _task({
  required String id,
  required TaskStatusEntity status,
  required String title,
  List<String> deps = const [],
}) {
  return TaskEntity(
    id: id,
    listId: 'l',
    title: title,
    updatedAtMillis: 0,
    status: status,
    dependencyTaskIds: deps,
  );
}
