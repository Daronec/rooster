# Navigation Guidelines

## Routing Library

- You SHOULD use `auto_route: 10.0.1` for navigation
- Routes are code-generated from `lib/features/navigation/app_router.gr.dart`
- Never manually edit `app_router.gr.dart` — run `make codegen` after route changes

## Route Definition Convention

### Name Transformation

The router uses `@AutoRouterConfig(replaceInRouteName: 'Flow|Screen,Route')`:
- `MainScreen` → `MainRoute`
- `AuthFlow` → `AuthRoute`
- `CreateMeetingScreen` → `CreateMeetingRoute`

### Route Paths

- All route path strings are centralized in `lib/features/navigation/app_route_paths.dart`
- Use string interpolation for composed paths: `static const nested = '$parent/$child';`
- Path params use `:paramName` syntax (e.g., `phone/otp-confirm/:phoneNumber`)
- Query params are passed via `rawQueryParams` in route args

### Route Structure

```
/splash                    — Initial splash
/auth                      — Auth flow
  /phone                   — Phone auth flow
    /otp-confirm/:phoneNumber — OTP confirmation
    /register              — Phone registration
/tabs                      — Main tabs wrapper
  /main                    — Main tab
    /my-partners           — Partners list
    /meeting-details/:eventId — Meeting details
    /report                — Report screen
  /calendar                — Calendar tab
    /create-absence        — Create absence
    /edit-absence/:id      — Edit absence
  /notifications           — Notifications tab
  /structure               — Structure tab
    /leaf/:departmentId    — Department leaf
```

## Platform-Specific Routing

### Desktop vs Mobile Routers

- `AppDesktopRouter` — extends `AppRouter` with desktop-specific routes
- `AppMobileRouter` — extends `AppRouter` with mobile-specific routes
- Desktop uses sidebar-style routes for certain screens (help, search, report)
- Mobile includes onboarding, update, delete account, and access control routes

### Desktop Sidebar Routes

Use `AppNavigaionUtils.sideBarRoute()` for desktop sidebar transitions:
```dart
CustomRoute.helpRoute(
  transitionsBuilder: TransitionsBuilders.slideLeft,
  barrierColor: Colors.black.withValues(alpha: 0.5),
  barrierLabel: false,
  duration: Duration(milliseconds: 300),
);
```

### Platform-Aware Route Builders

Use `AppNavigaionUtils.buildNativeRoute()` for platform-specific transitions:
- Desktop: slide-left with semi-transparent overlay
- iOS: `CupertinoPageRoute`
- Android: `MaterialPageRoute`

## Type-Safe Navigation

### Route Args

Routes carry typed args classes for compile-time safety:
```dart
// Navigating with parameters
await router.push(AbsenceDetailsRoute(
  id: '123',              // path param: /absence/:id
  userId: '456',          // query param: ?userId=456
));

// Receiving parameters
final args = router.current.pathParams;  // rawPathParams
final query = router.current.queryParams; // rawQueryParams
```

### Return Values

Routes can return typed values when popped:
```dart
final result = await router.push(CreateMeetingRoute());
if (result != null) {
  // result is MeetingDetailsEntity?
}
```

### WidgetModel Factory Injection

Screens using Elementary architecture accept `wmFactory` parameters:
```dart
await router.push(AdfsAuthorisationRoute(
  wmFactory: defaultAdfsAuthorisationWMFactory,
));
```

## Navigation Methods

### Programmatic Navigation

- Use `router.push()` for pushing new routes
- Use `router.replace()` for replacing current route
- Use `router.pop()` to pop current route
- Use `router.navigate()` for top-level navigation (resets stack)

### Conditional Navigation

Use `AppNavigaionUtils.handleAuthenticatedNavigation()` for post-auth routing:
- Checks platform and calendar auth state
- Routes to appropriate initial screen

Use `AppNavigaionUtils.getAuthRoute()` for auth screen selection:
- Dev with phone auth → `PhoneInputRoute`
- Web → `AdfsAuthorisationRoute`
- Mobile with ADFS → `AdfsAuthorisationRoute`
- Mobile without ADFS → `PhoneInputRoute`

## Navigation Best Practices

- You SHOULD define all route paths in `app_route_paths.dart`
- You SHOULD use typed route args for type safety
- You SHOULD use `AppNavigaionUtils` for platform-aware navigation
- You SHOULD implement both `buildMobile` and `buildDesktop` in screens
- You SHOULD place mobile/desktop widgets in separate `mobile/` and `desktop/` directories
- You SHOULD handle route parameters with proper null safety
- You SHOULD use `FlowRoute` for nested route stacks (e.g., auth flow, main tabs)

## Common Navigation Patterns

### Passing Data Between Screens

```dart
// Via route args (recommended for simple data)
await router.push(UserDetailsRoute(userId: user.id));

// Via DI/scope (recommended for complex objects)
// Access through repository or scope in the target screen's WM
```

### Navigating with Pre-populated Data

Use `AppNavigaionUtils.openMeetingEdit()` for editing existing meetings:
- Pre-populates route with meeting entity data
- Handles date, time, agents, participants, recurrence, attachments

### Error/Loading States in Navigation

- Show `BaseErrorWidget` or feature-specific error widgets on navigation failures
- Use `SnackQueueProvider.of(context).addSnack()` for error notifications
- Handle navigation errors in the WidgetModel, not in the screen widget
