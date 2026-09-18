# Testing Guidelines

## Testing Infrastructure

- You SHOULD use `flutter_test` as the core testing framework
- You SHOULD use `mocktail` for mocking (no `whenCalled` setup needed)
- You SHOULD use `surf_widget_test_composer` for widget golden tests
- You SHOULD use `golden_toolkit` for static UI component golden tests
- You SHOULD run `flutter test` before committing changes

## Test Configuration

- Global test setup is in `test/flutter_test_config.dart`
- Tests run with light theme, Russian locale (`ru-RU`), and 3 device sizes:
  - `iphone11` (414x896)
  - `pixel 4a` (393x851)
  - `iphone_se_1` (320x568)
- Golden comparison uses 18% pixel tolerance for minor rendering variations

## Unit Testing Patterns

### Pure Utility Functions

```dart
void main() {
  group('VersionUtil', () {
    group('compareVersions', () {
      test('should return true when first version is greater', () {
        expect(VersionUtil.compareVersions('1.1.0', '1.0.3'), isTrue);
      });
    });
  });
}
```

- Use `group`/`test`/`expect` from `flutter_test`
- No mocking needed for pure functions
- Group related tests logically

### WidgetModel / Domain Testing with mocktail

```dart
class MockRepository extends Mock implements IRepository {}

void main() {
  late TestableModel model;
  late MockRepository mockRepo;

  setUpAll(() {
    mockRepo = MockRepository();
    when(() => mockRepo.someMethod()).thenAnswer((_) => Future.value(Result.ok(data)));
  });

  setUp(() {
    model = TestableModel(mockRepo);
  });

  test('Should call repository method', () async {
    await model.doSomething();
    verify(() => mockRepo.someMethod()).called(1);
  });
}
```

- Create mock classes extending `Mock` from mocktail
- Use `setUpAll` for shared mocks, `setUp` for fresh instances per test
- Use `when().thenReturn()` for stubbing, `verify().called()` for assertions
- Use `thenAnswer` for async returns

## Widget Testing Patterns

### Using surf_widget_test_composer

```dart
testWidget<ExampleScreen>(
  widgetBuilder: (_, __) => const ExampleScreen().build(wm),
  setup: (context, __) {
    when(() => wm.someState).thenReturn(ValueNotifier(value));
    when(() => wm.l10n).thenReturn(context.l10n);
  },
  autoHeight: true,
);
```

- Use `testWidget<T>()` from `surf_widget_test_composer`
- Mock widget model in `setup` callback using `mocktail`
- Set `autoHeight: true` for variable-height content
- The composer handles multi-device and multi-theme rendering automatically

### Using golden_toolkit for Static UI Components

```dart
testGoldens('Golden App Alert', (tester) async {
  final builder = GoldenBuilder.column(bgColor: Colors.white)
    ..addScenario('With title', AppAlert(title: 'Title', content: 'Content'))
    ..addScenario('Without title', AppAlert(content: 'Content'));

  await tester.pumpWidgetBuilder(
    builder.build(),
    surfaceSize: const Size(800, 600),
  );
  await screenMatchesGolden(tester, 'app_alert');
});
```

- Use `GoldenBuilder.column` to compose multiple visual scenarios
- Each `addScenario` creates one visual test case in the golden image
- Use `testGoldens` (not `testWidgets`) for golden tests
- Name golden files descriptively (e.g., `app_alert`, `dash_screen`)

## Golden Test Organization

- Store goldens in `test/features/<feature>/goldens/` or `test/uikit/<component>/goldens/`
- Naming convention: `<component>.light.<device>.png` and `<component>.dark.<device>.png`
- Example: `dash_screen.light.iphone11.png`, `dash_screen.dark.pixel 4a.png`
- Update goldens with `scripts/reset_goldens.sh` when changes are intentional

## Testing Widget Models

- Test the WM logic (state changes, method calls) separately from UI rendering
- Verify repository interactions via `verify()`
- Test loading/content/error state transitions
- Test error handling paths

```dart
test('Should show error on repository failure', () async {
  when(() => mockRepo.fetchData()).thenThrow(ApiFailure(original: Exception('fail')));
  
  await model.loadData();
  
  expect(model.state.value, isA<ResultFailed>());
  verify(() => mockRepo.fetchData()).called(1);
});
```

## Testing Best Practices

- You SHOULD test one logical behavior per test
- You SHOULD name tests descriptively: `should_do_something_when_condition`
- You SHOULD use `group` to organize related tests
- You SHOULD mock external dependencies (API, storage, navigation)
- You SHOULD test both success and error paths
- You SHOULD test null/edge cases for nullable fields
- You SHOULD NOT test framework behavior (Flutter widgets work as documented)
- You SHOULD update golden tests when UI changes are intentional

## Coverage

- Run `scripts/check_coverage.sh` to verify test coverage
- Aim for high coverage on domain logic, converters, and utilities
- UI tests are valuable for critical user flows and golden comparisons
