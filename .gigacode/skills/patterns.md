# Common Patterns & Recipes

## Recipe 1: Create a New Screen

### Step 1: Create domain entities (if needed)
`lib/features/<feature>/domain/entities/<entity>.dart`
```dart
// Use freezed for immutable data classes:
@freezed
class MyEntity with _$MyEntity {
  const factory MyEntity({required String id, required String name}) = _MyEntity;
}
```

### Step 2: Create repository interface
`lib/features/<feature>/domain/repositories/i_<feature>_repository.dart`
```dart
abstract interface class I<Feature>Repository {
  RequestOperation<List<MyEntity>, Failure> fetchItems();
}
```

### Step 3: Create repository implementation
`lib/features/<feature>/data/repositories/<feature>_repository.dart`
```dart
class <Feature>Repository extends BaseRepository implements I<Feature>Repository {
  <Feature>Repository({required ILogWriter logWriter}) : super(logWriter: logWriter);

  @override
  RequestOperation<List<MyEntity>, Failure> fetchItems() {
    return makeCall<MyEntityListDto, ApiFailure>(
      () async => _api.getItems().then((r) => MyEntityListDto.fromMap(r.data)),
    ).then((result) => result.map((dto) => dto.items.map((e) => MyEntityConverter.fromMap(e)).toList()));
  }
}
```

### Step 4: Create feature scope
`lib/features/<feature>/di/<feature>_scope.dart`
```dart
abstract interface class I<Feature>Scope implements IDisposableObject {
  I<Feature>Repository get repository;
}

class <Feature>Scope implements I<Feature>Scope {
  final I<Feature>Repository repository;
  <Feature>Scope(this.repository);

  factory <Feature>Scope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();
    return <Feature>Scope(<Feature>Repository(logWriter: appScope.logger));
  }

  @override
  void dispose() {}
}
```

### Step 5: Create the 3 screen files

**`*_model.dart`** — Business logic:
```dart
class <Screen>Model extends ElementaryModel {
  final I<Feature>Repository repository;

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueListenable<bool> get isLoading => _isLoading;

  <Screen>Model({required this.repository});

  @override
  Future<void> init() async {
    _isLoading.value = true;
    try {
      // Business logic here
    } finally {
      _isLoading.value = false;
    }
  }
}
```

**`*_wm.dart`** — Widget model:
```dart
class <Screen>WM extends BaseWidgetModel<<Flow>, I<Screen>WM> {
  final SnackQueueController snackController;

  <Screen>WM(<Screen>Model model, {required this.snackController}) : super(model: model);

  factory <Screen>WM.defaultFactory(BuildContext context) {
    final scope = context.read<I<Feature>Scope>();
    final snackController = SnackQueueProvider.of(context);
    return <Screen>WM(
      <Screen>Model(repository: scope.repository),
      snackController: snackController,
    );
  }

  // Навигация через context.router
  void goToNextScreen() {
    context.router.push(NextRoute());
  }
}

abstract interface class I<Screen>WM extends IBaseWidgetModel {
  void goToNextScreen();
}
```

**`*_screen.dart`** — UI:
```dart
class <Screen>Screen extends BaseWidget<I<Screen>WM> {
  @override
  Widget buildMobile(I<Screen>WM wm) => <Screen>View(wm: wm);

  @override
  Widget buildDesktop(I<Screen>WM wm) => <Screen>View(wm: wm);
}

// View в отдельном файле или inline
class <Screen>View extends StatelessWidget {
  const <Screen>View({required this.wm, super.key});
  final I<Screen>WM wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = wm.colorScheme;
    final textScheme = wm.textScheme;

    return AppScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).title)),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          children: [
            const Height(AppSizes.double16),
            Text('Hello', style: textScheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
```

### Step 6: Add route
In `lib/features/navigation/app_router.dart`:
```dart
AutoRoute(path: '/<feature>', page: <Feature>FlowRoute.page,
  children: [AutoRoute(page: <Screen>Route.page, initial: true)],
),
```

### Step 7: Register route path
In `lib/app_routing/app_route_paths.dart`:
```dart
static const String <feature> = '/<feature>';
```

## Recipe 2: Make an API Call

### In Repository:
```dart
RequestOperation<MyEntity, Failure> fetchItem(String id) {
  return makeCall<MyEntityDto, ApiFailure>(
    () async => _api.getItem(id).then((r) => MyEntityDto.fromMap(r.data)),
  );
}
```

### In WM/Model:
```dart
final result = await repository.fetchItem(id);
result.when(
  (entity) => _handleSuccess(entity),
  error: (failure) {
    if (failure is TimeoutFailure) {
      snackController.show(AppLocalizations.of(context).timeoutError);
    } else if (failure is NoInternetFailure) {
      snackController.show(AppLocalizations.of(context).noInternetError);
    } else {
      snackController.show(AppLocalizations.of(context).genericError);
    }
  },
);
```

## Recipe 3: Add a Route

1. Define in `app_router.dart`:
```dart
AutoRoute(path: '/new-screen', page: NewScreenRoute.page),
```

2. Add path constant in `app_route_paths.dart`:
```dart
static const String newScreen = '/new-screen';
```

3. Run code generation:
```bash
flutter pub run build_runner build
```

4. Navigate from WM через `context.router`:
```dart
// ✅ В WM
void goToNext() {
  context.router.push(NewScreenRoute());
}

// С аргументами
context.router.push(NewScreenRoute(args: NewScreenRouteArgs(param: value)));
```

## Recipe 4: Add DI Registration

### In App Scope:
1. Add to `IAppScope` interface in `app_scope.dart`
2. Add implementation in `app_scope_register.dart`

### In Feature Scope:
1. Create `<feature>_scope.dart` with `I<Feature>Scope` interface
2. Create factory method `<Feature>Scope.create(BuildContext)`
3. Wrap route in `wrappedRoute()` with `Provider<I<Feature>Scope>`

## Recipe 5: Use Snack Queue

```dart
// Get controller in WM factory
final snackController = SnackQueueProvider.of(context);

// Show messages — через локализацию
snackController.show(AppLocalizations.of(context).successMessage);
snackController.showError(AppLocalizations.of(context).errorMessage);

// Pass between screens via route args if needed
```

## Recipe 6: Offline-First Data Pattern

```dart
class MyRepository extends BaseRepository {
  // 1. Persist to Hive first
  Future<void> saveEntity(MyEntity entity) async {
    await _hiveBox.put(entity.id, entity.toMap());
    
    // 2. Update in-memory state
    _entities.value = [..._entities.value.where((e) => e.id != entity.id), entity];
    
    // 3. Enqueue sync
    _enqueueSync(type: SyncOperationType.upsertMyEntity, payload: entity.toMap());
  }
  
  // 4. Load from Hive on init
  Future<void> init() async {
    final data = await _hiveBox.getAll([...keys]);
    _entities.value = data.map((k, v) => MyEntity.fromMap(v)).toList();
  }
}
```

## Recipe 7: Reactive State in WM

```dart
class MyWM extends BaseWidgetModel<MyFlow, IMyWM> with _$MyWM {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueListenable<bool> get isLoading => _isLoading;
  
  final ValueNotifier<MyEntity?> _entity = ValueNotifier(null);
  ValueListenable<MyEntity?> get entity => _entity;
  
  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      final result = await repository.fetchData();
      result.when(
        ok: (data) => _entity.value = data,
        failed: (f) => snackController.showError(f.message),
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
```

## Recipe 8: Use Theme- Aware UI Kit

```dart
// ✅ В View получать тему из wm
class MyView extends StatelessWidget {
  const MyView({required this.wm, super.key});
  final IMyWM wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = wm.colorScheme;
    final textScheme = wm.textScheme;

    return Column(
      children: [
        const Height(AppSizes.double16),
        Text('Hello', style: textScheme.bodyMedium),
        const SizedBox(height: 8), // или const Height(AppSizes.double8)
        Container(
          padding: AppSizes.edgeInsetsAll16,
          color: colorScheme.primaryContainer,
          child: Text('Content', style: textScheme.bodyLarge),
        ),
        AppPrimaryButton(
          text: AppLocalizations.of(context).submit,
          onPressed: () {},
        ),
      ],
    );
  }
}
```

## Key Files Reference

| Purpose | File Path |
|---------|-----------|
| Base Widget | `lib/core/architecture/presentation/base_widget.dart` |
| Base Widget Model | `lib/core/architecture/presentation/base_widget_model.dart` |
| Result Monad | `lib/core/architecture/domain/entity/result.dart` |
| Base Repository | `lib/core/architecture/data/repository/base_repository.dart` |
| App Scope | `lib/features/app/di/app_scope.dart` |
| App DI Register | `lib/features/app/di/app_scope_register.dart` |
| App Router | `lib/features/navigation/app_router.dart` |
| Route Paths | `lib/app_routing/app_route_paths.dart` |
| Dio Config | `lib/api/app_dio_configurator.dart` |
| Snack Queue | `lib/common/utils/snack_queue/` |
| Env Config | `lib/config/app_dotenv.dart` |
| Sync Queue | `lib/core/sync/i_sync_queue.dart` |
| Sync Manager | `lib/core/sync/sync_manager_impl.dart` |
