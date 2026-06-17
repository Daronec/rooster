import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_dependency_validator.dart';

void main() {
  group('TaskDependencyValidator', () {
    test('отклоняет ссылку задачи на саму себя', () {
      const taskId = 'a';
      final allTasks = <String, TaskEntity>{
        taskId: _task(id: taskId, deps: [taskId]),
      };

      final result = TaskDependencyValidator.validate(
        taskId: taskId,
        dependencyTaskIds: [taskId],
        allTasks: allTasks,
      );

      expect(result.isValid, isFalse);
      expect(result.error, TaskDependencyValidationError.selfDependency);
    });

    test('отклоняет несуществующий id зависимости', () {
      const taskId = 'a';
      final allTasks = <String, TaskEntity>{
        taskId: _task(id: taskId, deps: ['ghost']),
      };

      final result = TaskDependencyValidator.validate(
        taskId: taskId,
        dependencyTaskIds: ['ghost'],
        allTasks: allTasks,
      );

      expect(result.isValid, isFalse);
      expect(result.error, TaskDependencyValidationError.unknownDependency);
    });

    test('отклоняет цикл A → B → A', () {
      final allTasks = <String, TaskEntity>{
        'a': _task(id: 'a', deps: ['b']),
        'b': _task(id: 'b', deps: ['a']),
      };

      final result = TaskDependencyValidator.validate(
        taskId: 'a',
        dependencyTaskIds: ['b'],
        allTasks: allTasks,
      );

      expect(result.isValid, isFalse);
      expect(result.error, TaskDependencyValidationError.cyclicDependencies);
    });

    test('принимает линейную цепочку без цикла', () {
      final allTasks = <String, TaskEntity>{
        'a': _task(id: 'a', deps: ['b']),
        'b': _task(id: 'b', deps: const []),
      };

      final result = TaskDependencyValidator.validate(
        taskId: 'a',
        dependencyTaskIds: ['b'],
        allTasks: allTasks,
      );

      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });
  });
}

TaskEntity _task({
  required String id,
  required List<String> deps,
}) {
  return TaskEntity(
    id: id,
    listId: 'list',
    title: id,
    updatedAtMillis: 0,
    dependencyTaskIds: deps,
  );
}
