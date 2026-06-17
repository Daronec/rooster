import 'package:flutter/material.dart';
import 'package:rooster/features/navigation/desktop_main_navigation_bridge.dart';

/// Наследуемый доступ к [DesktopMainNavigationBridge] для дерева под оболочкой.
class DesktopShellNavigationHost extends InheritedWidget {
  /// Создаёт область видимости моста навигации десктопной оболочки.
  const DesktopShellNavigationHost({
    required this.bridge,
    required super.child,
    super.key,
  });

  /// Мост вкладок и вторичного стека.
  final DesktopMainNavigationBridge bridge;

  /// Возвращает мост, если виджет построен внутри оболочки.
  static DesktopMainNavigationBridge? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DesktopShellNavigationHost>()
        ?.bridge;
  }

  @override
  bool updateShouldNotify(covariant DesktopShellNavigationHost oldWidget) {
    return oldWidget.bridge != bridge;
  }
}
