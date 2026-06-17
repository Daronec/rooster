import 'package:flutter/foundation.dart';
import 'package:union_state/union_state.dart';

/// [ValueListenable], несущий [UnionState] с полезной нагрузкой [T].
///
/// Для списков в UI: тип слушателя — `UnionStateListenable<List<Item>>`; разметка
/// по веткам loading / content / failure — `UnionStateListBody` в
/// `package:rooster/util/union_state/union_state_list_body.dart`.
typedef UnionStateListenable<T> = ValueListenable<UnionState<T>>;
