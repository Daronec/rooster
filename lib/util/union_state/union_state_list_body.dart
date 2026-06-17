import 'package:flutter/widgets.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:union_state/union_state.dart';

/// Тело экрана для [UnionState] с полезной нагрузкой [List] элементов типа [Item].
///
/// Делегирует в [UnionStateListenableBuilder] без изменения поведения: ответственность
/// этого виджета — только зафиксировать шаблон «список в UnionState» и снять дублирование
/// `UnionStateListenableBuilder<List<…>>` на экранах дома, комнат, сцен и систем.
/// Разметка, навигация и сценарии остаются в виджетах и WM соответствующих фич.
class UnionStateListBody<Item> extends StatelessWidget {
  /// Создаёт обёртку для спискового UnionState.
  const UnionStateListBody({
    required this.unionStateListenable, required this.loadingBuilder, required this.builder, required this.failureBuilder, super.key,
  });

  /// Источник состояния (`loading` / `content` / `failure`) со списком [Item].
  final UnionStateListenable<List<Item>> unionStateListenable;

  /// UI при загрузке; во втором аргументе билдера — кэш последнего списка, если был.
  final LoadingWidgetBuilder<List<Item>> loadingBuilder;

  /// UI при успехе с непустым или пустым списком.
  final DataWidgetBuilder<List<Item>> builder;

  /// UI при ошибке; в третьем аргументе билдера — кэш последнего списка, если был.
  final FailureWidgetBuilder<List<Item>> failureBuilder;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<List<Item>>(
      unionStateListenable: unionStateListenable,
      loadingBuilder: loadingBuilder,
      builder: builder,
      failureBuilder: failureBuilder,
    );
  }
}
