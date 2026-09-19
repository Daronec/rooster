# Flutter Animations Guidelines

## Animation Types

### Implicit Animations (simple state-driven changes)

Use for simple property transitions triggered by state changes:
- `AnimatedContainer` — animate size, color, padding, constraints
- `AnimatedOpacity` — fade in/out
- `AnimatedSwitcher` — transition between two widgets
- `TweenAnimationBuilder` — animate any numeric value

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isLoading ? 100 : 200,
  child: child,
);
```

### Explicit Animations (full lifecycle control)

Use for animations requiring control, repetition, or gesture-driven values:
- `AnimationController` + `Tween` + `CurvedAnimation`
- `AnimatedBuilder` — efficient rebuild only animated parts
- `AnimatedWidget` — reusable animated widget

```dart
class MyAnimatedWidget extends AnimatedWidget {
  const MyAnimatedWidget({required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final progress = listenable.value;
    return Opacity(opacity: progress, child: child);
  }
}
```

### Hero Animations (shared element transitions)

Use for shared visual elements between routes:
```dart
Hero(
  tag: 'user_avatar_$userId',
  child: CircleAvatar(child: Image.network(url)),
);
```

### Staggered Animations (sequential effects)

Use for list/menu reveal with offset timing:
```dart
AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 500),
);

// Use Interval for staggered timing
Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: controller,
    curve: Interval(0.0, 0.5, curve: Curves.easeOut),
  ),
);
```

## Animation Best Practices

- You SHOULD prefer implicit animations for simple state-driven changes
- You SHOULD use `AnimatedBuilder` instead of `setState` in animation listeners
- You SHOULD always dispose `AnimationController` in `dispose()`
- You SHOULD respect `MediaQuery.disableAnimations` for accessibility
- You SHOULD use `Curves.easeInOut` for most UI transitions
- You SHOULD use `Curves.easeOut` for entrance animations
- You SHOULD use `Curves.easeIn` for exit animations
- You SHOULD keep animations under 500ms for responsive feel
- You SHOULD avoid animating layout properties that cause rebuilds
- You SHOULD use `AnimatedSwitcher` for content changes with transitions

## Common Animation Patterns

### Loading Spinner

```dart
RotationTransition(
  turns: Tween(begin: 0.0, end: 1.0).animate(controller),
  child: CircularProgressIndicator(),
);
```

### Fade In on Load

```dart
AnimatedOpacity(
  opacity: isLoading ? 0.0 : 1.0,
  duration: Duration(milliseconds: 300),
  child: child,
);
```

### Scale on Press

```dart
AnimatedScale(
  scale: isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 150),
  child: child,
);
```

### Slide Transition

```dart
AnimatedSlide(
  offset: offset,
  duration: Duration(milliseconds: 300),
  child: child,
);
```

## Animation Constraints

- Do not add `AnimationController` when an implicit widget gives the same behavior
- Do not leave controllers, listeners, or timers undisposed
- Do not use `timeDilation` in production code (debug only)
- Do not make accessibility optional for user-facing motion
- Do not copy animation code blindly — adapt to the project's style

## Validation

- Run `dart format` on edited Dart files
- Run `flutter analyze` for the project
- Run widget tests when animation changes affect navigation or gestures
- Check `MediaQuery.disableAnimations` for reduced-motion support
