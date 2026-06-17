import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:union_state/union_state.dart' show UnionState, UnionStateContent;

/// Маркер готовности тела экрана без полезной нагрузки в [UnionState].
///
/// Используется в [UnionStateContent], когда основные данные экрана лежат
/// в отдельных [ValueListenable] (например список задач), а [UnionState]
/// описывает только фазы loading / content / failure.
final class EmptyScreenBody {
  const EmptyScreenBody._();

  /// Единственный экземпляр для передачи в [UnionStateContent].
  static const EmptyScreenBody instance = EmptyScreenBody._();
}
