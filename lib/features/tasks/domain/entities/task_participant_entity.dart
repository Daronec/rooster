/// Участник, которого можно выбрать в задаче (например исполнитель).
final class TaskParticipantEntity {
  /// Создаёт участника.
  const TaskParticipantEntity({
    required this.teamId,
    required this.userId,
    required this.label,
  });

  /// Id команды Appwrite, из которой выбран участник.
  final String teamId;

  /// Id пользователя (Appwrite `userId` в членстве команды).
  final String userId;

  /// Текст для отображения в UI (имя, email или fallback).
  final String label;
}

