// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AiChatFlow]
class AiChatFlowRoute extends PageRouteInfo<void> {
  const AiChatFlowRoute({List<PageRouteInfo>? children})
    : super(AiChatFlowRoute.name, initialChildren: children);

  static const String name = 'AiChatFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AiChatFlow();
    },
  );
}

/// generated route for
/// [AiChatScreen]
class AiChatRoute extends PageRouteInfo<void> {
  const AiChatRoute({List<PageRouteInfo>? children})
    : super(AiChatRoute.name, initialChildren: children);

  static const String name = 'AiChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AiChatScreen();
    },
  );
}

/// generated route for
/// [AuthFlow]
class AuthFlowRoute extends PageRouteInfo<void> {
  const AuthFlowRoute({List<PageRouteInfo>? children})
    : super(AuthFlowRoute.name, initialChildren: children);

  static const String name = 'AuthFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthFlow();
    },
  );
}

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [CreatePlanScreen]
class CreatePlanRoute extends PageRouteInfo<void> {
  const CreatePlanRoute({List<PageRouteInfo>? children})
    : super(CreatePlanRoute.name, initialChildren: children);

  static const String name = 'CreatePlanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreatePlanScreen();
    },
  );
}

/// generated route for
/// [CreatePlanTaskScreen]
class CreatePlanTaskRoute extends PageRouteInfo<CreatePlanTaskRouteArgs> {
  CreatePlanTaskRoute({
    required String planId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CreatePlanTaskRoute.name,
         args: CreatePlanTaskRouteArgs(planId: planId, key: key),
         rawPathParams: {'planId': planId},
         initialChildren: children,
       );

  static const String name = 'CreatePlanTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatePlanTaskRouteArgs>(
        orElse: () =>
            CreatePlanTaskRouteArgs(planId: pathParams.getString('planId')),
      );
      return CreatePlanTaskScreen(planId: args.planId, key: args.key);
    },
  );
}

class CreatePlanTaskRouteArgs {
  const CreatePlanTaskRouteArgs({required this.planId, this.key});

  final String planId;

  final Key? key;

  @override
  String toString() {
    return 'CreatePlanTaskRouteArgs{planId: $planId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatePlanTaskRouteArgs) return false;
    return planId == other.planId && key == other.key;
  }

  @override
  int get hashCode => planId.hashCode ^ key.hashCode;
}

/// generated route for
/// [CreateTaskListScreen]
class CreateTaskListRoute extends PageRouteInfo<CreateTaskListRouteArgs> {
  CreateTaskListRoute({Key? key, String? listId, List<PageRouteInfo>? children})
    : super(
        CreateTaskListRoute.name,
        args: CreateTaskListRouteArgs(key: key, listId: listId),
        initialChildren: children,
      );

  static const String name = 'CreateTaskListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateTaskListRouteArgs>(
        orElse: () => const CreateTaskListRouteArgs(),
      );
      return CreateTaskListScreen(key: args.key, listId: args.listId);
    },
  );
}

class CreateTaskListRouteArgs {
  const CreateTaskListRouteArgs({this.key, this.listId});

  final Key? key;

  final String? listId;

  @override
  String toString() {
    return 'CreateTaskListRouteArgs{key: $key, listId: $listId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateTaskListRouteArgs) return false;
    return key == other.key && listId == other.listId;
  }

  @override
  int get hashCode => key.hashCode ^ listId.hashCode;
}

/// generated route for
/// [CreateTaskScreen]
class CreateTaskRoute extends PageRouteInfo<CreateTaskRouteArgs> {
  CreateTaskRoute({
    Key? key,
    String? taskId,
    String? parentTaskId,
    String? initialTitle,
    String? initialDescription,
    List<String> initialDependencyTaskIds = const [],
    List<String> initialDependentTaskIds = const [],
    List<PageRouteInfo>? children,
  }) : super(
         CreateTaskRoute.name,
         args: CreateTaskRouteArgs(
           key: key,
           taskId: taskId,
           parentTaskId: parentTaskId,
           initialTitle: initialTitle,
           initialDescription: initialDescription,
           initialDependencyTaskIds: initialDependencyTaskIds,
           initialDependentTaskIds: initialDependentTaskIds,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateTaskRouteArgs>(
        orElse: () => const CreateTaskRouteArgs(),
      );
      return CreateTaskScreen(
        key: args.key,
        taskId: args.taskId,
        parentTaskId: args.parentTaskId,
        initialTitle: args.initialTitle,
        initialDescription: args.initialDescription,
        initialDependencyTaskIds: args.initialDependencyTaskIds,
        initialDependentTaskIds: args.initialDependentTaskIds,
      );
    },
  );
}

class CreateTaskRouteArgs {
  const CreateTaskRouteArgs({
    this.key,
    this.taskId,
    this.parentTaskId,
    this.initialTitle,
    this.initialDescription,
    this.initialDependencyTaskIds = const [],
    this.initialDependentTaskIds = const [],
  });

  final Key? key;

  final String? taskId;

  final String? parentTaskId;

  final String? initialTitle;

  final String? initialDescription;

  final List<String> initialDependencyTaskIds;

  final List<String> initialDependentTaskIds;

  @override
  String toString() {
    return 'CreateTaskRouteArgs{key: $key, taskId: $taskId, parentTaskId: $parentTaskId, initialTitle: $initialTitle, initialDescription: $initialDescription, initialDependencyTaskIds: $initialDependencyTaskIds, initialDependentTaskIds: $initialDependentTaskIds}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateTaskRouteArgs) return false;
    return key == other.key &&
        taskId == other.taskId &&
        parentTaskId == other.parentTaskId &&
        initialTitle == other.initialTitle &&
        initialDescription == other.initialDescription &&
        const ListEquality<String>().equals(
          initialDependencyTaskIds,
          other.initialDependencyTaskIds,
        ) &&
        const ListEquality<String>().equals(
          initialDependentTaskIds,
          other.initialDependentTaskIds,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      taskId.hashCode ^
      parentTaskId.hashCode ^
      initialTitle.hashCode ^
      initialDescription.hashCode ^
      const ListEquality<String>().hash(initialDependencyTaskIds) ^
      const ListEquality<String>().hash(initialDependentTaskIds);
}

/// generated route for
/// [DecisionBlockedScreen]
class DecisionBlockedRoute extends PageRouteInfo<void> {
  const DecisionBlockedRoute({List<PageRouteInfo>? children})
    : super(DecisionBlockedRoute.name, initialChildren: children);

  static const String name = 'DecisionBlockedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionBlockedScreen();
    },
  );
}

/// generated route for
/// [DecisionFlow]
class DecisionFlowRoute extends PageRouteInfo<void> {
  const DecisionFlowRoute({List<PageRouteInfo>? children})
    : super(DecisionFlowRoute.name, initialChildren: children);

  static const String name = 'DecisionFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionFlow();
    },
  );
}

/// generated route for
/// [DecisionResourcesScreen]
class DecisionResourcesRoute extends PageRouteInfo<void> {
  const DecisionResourcesRoute({List<PageRouteInfo>? children})
    : super(DecisionResourcesRoute.name, initialChildren: children);

  static const String name = 'DecisionResourcesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionResourcesScreen();
    },
  );
}

/// generated route for
/// [DecisionTodayScreen]
class DecisionTodayRoute extends PageRouteInfo<void> {
  const DecisionTodayRoute({List<PageRouteInfo>? children})
    : super(DecisionTodayRoute.name, initialChildren: children);

  static const String name = 'DecisionTodayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionTodayScreen();
    },
  );
}

/// generated route for
/// [DevPanelFlow]
class DevPanelFlowRoute extends PageRouteInfo<void> {
  const DevPanelFlowRoute({List<PageRouteInfo>? children})
    : super(DevPanelFlowRoute.name, initialChildren: children);

  static const String name = 'DevPanelFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DevPanelFlow();
    },
  );
}

/// generated route for
/// [DevPanelScreen]
class DevPanelRoute extends PageRouteInfo<void> {
  const DevPanelRoute({List<PageRouteInfo>? children})
    : super(DevPanelRoute.name, initialChildren: children);

  static const String name = 'DevPanelRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DevPanelScreen();
    },
  );
}

/// generated route for
/// [MainDesktopShellScreen]
class MainDesktopShellRoute extends PageRouteInfo<void> {
  const MainDesktopShellRoute({List<PageRouteInfo>? children})
    : super(MainDesktopShellRoute.name, initialChildren: children);

  static const String name = 'MainDesktopShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const MainDesktopShellScreen());
    },
  );
}

/// generated route for
/// [MainFlow]
class MainFlowRoute extends PageRouteInfo<void> {
  const MainFlowRoute({List<PageRouteInfo>? children})
    : super(MainFlowRoute.name, initialChildren: children);

  static const String name = 'MainFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainFlow();
    },
  );
}

/// generated route for
/// [PlanningFlow]
class PlanningFlowRoute extends PageRouteInfo<void> {
  const PlanningFlowRoute({List<PageRouteInfo>? children})
    : super(PlanningFlowRoute.name, initialChildren: children);

  static const String name = 'PlanningFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlanningFlow();
    },
  );
}

/// generated route for
/// [PlanningScreen]
class PlanningRoute extends PageRouteInfo<void> {
  const PlanningRoute({List<PageRouteInfo>? children})
    : super(PlanningRoute.name, initialChildren: children);

  static const String name = 'PlanningRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlanningScreen();
    },
  );
}

/// generated route for
/// [ProfileFlow]
class ProfileFlowRoute extends PageRouteInfo<void> {
  const ProfileFlowRoute({List<PageRouteInfo>? children})
    : super(ProfileFlowRoute.name, initialChildren: children);

  static const String name = 'ProfileFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileFlow();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [RootAuthGateScreen]
class RootAuthGateRoute extends PageRouteInfo<void> {
  const RootAuthGateRoute({List<PageRouteInfo>? children})
    : super(RootAuthGateRoute.name, initialChildren: children);

  static const String name = 'RootAuthGateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootAuthGateScreen();
    },
  );
}

/// generated route for
/// [SettingsFlow]
class SettingsFlowRoute extends PageRouteInfo<void> {
  const SettingsFlowRoute({List<PageRouteInfo>? children})
    : super(SettingsFlowRoute.name, initialChildren: children);

  static const String name = 'SettingsFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsFlow();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [TaskChangeHistoryScreen]
class TaskChangeHistoryRoute extends PageRouteInfo<TaskChangeHistoryRouteArgs> {
  TaskChangeHistoryRoute({
    required String taskId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TaskChangeHistoryRoute.name,
         args: TaskChangeHistoryRouteArgs(taskId: taskId, key: key),
         initialChildren: children,
       );

  static const String name = 'TaskChangeHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskChangeHistoryRouteArgs>();
      return TaskChangeHistoryScreen(taskId: args.taskId, key: args.key);
    },
  );
}

class TaskChangeHistoryRouteArgs {
  const TaskChangeHistoryRouteArgs({required this.taskId, this.key});

  final String taskId;

  final Key? key;

  @override
  String toString() {
    return 'TaskChangeHistoryRouteArgs{taskId: $taskId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskChangeHistoryRouteArgs) return false;
    return taskId == other.taskId && key == other.key;
  }

  @override
  int get hashCode => taskId.hashCode ^ key.hashCode;
}

/// generated route for
/// [TaskDetailScreen]
class TaskDetailRoute extends PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({
    required String taskId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TaskDetailRoute.name,
         args: TaskDetailRouteArgs(taskId: taskId, key: key),
         initialChildren: children,
       );

  static const String name = 'TaskDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return TaskDetailScreen(taskId: args.taskId, key: args.key);
    },
  );
}

class TaskDetailRouteArgs {
  const TaskDetailRouteArgs({required this.taskId, this.key});

  final String taskId;

  final Key? key;

  @override
  String toString() {
    return 'TaskDetailRouteArgs{taskId: $taskId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskDetailRouteArgs) return false;
    return taskId == other.taskId && key == other.key;
  }

  @override
  int get hashCode => taskId.hashCode ^ key.hashCode;
}

/// generated route for
/// [TaskListsFlow]
class TaskListsFlowRoute extends PageRouteInfo<void> {
  const TaskListsFlowRoute({List<PageRouteInfo>? children})
    : super(TaskListsFlowRoute.name, initialChildren: children);

  static const String name = 'TaskListsFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskListsFlow();
    },
  );
}

/// generated route for
/// [TaskListsScreen]
class TaskListsRoute extends PageRouteInfo<void> {
  const TaskListsRoute({List<PageRouteInfo>? children})
    : super(TaskListsRoute.name, initialChildren: children);

  static const String name = 'TaskListsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskListsScreen();
    },
  );
}

/// generated route for
/// [TasksFlow]
class TasksFlowRoute extends PageRouteInfo<void> {
  const TasksFlowRoute({List<PageRouteInfo>? children})
    : super(TasksFlowRoute.name, initialChildren: children);

  static const String name = 'TasksFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TasksFlow();
    },
  );
}

/// generated route for
/// [TasksScreen]
class TasksRoute extends PageRouteInfo<void> {
  const TasksRoute({List<PageRouteInfo>? children})
    : super(TasksRoute.name, initialChildren: children);

  static const String name = 'TasksRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TasksScreen();
    },
  );
}
