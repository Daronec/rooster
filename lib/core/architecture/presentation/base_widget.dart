import 'package:elementary/elementary.dart';
import 'package:flutter/widgets.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';

/// {@template base_model.class}
/// Base class for all [ElementaryWidget]s in the application.
/// {@endtemplate}
abstract class BaseWidget<T extends IBaseWidgetModel>
    extends ElementaryWidget<IBaseWidgetModel> {
  /// {@macro base_model.class}
  const BaseWidget(super.wmFactory, {super.key});

  /// Build widget for desktop devices.
  Widget buildDesktop(T wm);

  /// Build widget for mobile devices.
  Widget buildMobile(T wm);

  @override
  Widget build(covariant T wm) {
    if (wm.isDesktop) {
      // ignore: avoid-returning-widgets
      return buildDesktop(wm);
    }

    // ignore: avoid-returning-widgets
    return buildMobile(wm);
  }
}
