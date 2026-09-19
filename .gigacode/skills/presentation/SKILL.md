# Presentation Layer Implementation

## Model Implementation

### Base Structure
- You SHOULD use `final class` declaration
- You SHOULD extend `ElementaryModel`
- You SHOULD use private repository fields with underscore prefix
- You SHOULD document class with `{@template}` and `{@macro}` tags

### Constructor
- You SHOULD inject repositories via constructor
- You SHOULD mark parameters as `required`
- You SHOULD pass `errorHandler` to super constructor

### Methods
- You SHOULD delegate directly to repository methods
- You SHOULD document all public methods
- You SHOULD preserve repository return types
- You SHOULD NEVER transform data in model layer

## Widget Model (WM) Implementation

### Class Structure
You SHOULD implement three parts:
1. Factory function (e.g., `defaultExampleWMFactory`)
2. Interface (e.g., `IExampleWM`)
3. Concrete class (e.g., `ExampleWM`)

### Interface
- You SHOULD use `abstract interface class` syntax
- You SHOULD prefix with `I` (e.g., `IExampleWM`)
- You SHOULD implement `IBaseWidgetModel`

### Factory Function
- You SHOULD name as `default[ClassName]WMFactory`
- You SHOULD accept `BuildContext` as first parameter

### State Management
- You SHOULD use `UnionStateNotifier<T>` for complex states (loading/content/error)
- You SHOULD use `ValueNotifier<T>` for simpler states
- You SHOULD declare as `final` fields with defaults

### Constructor
- You SHOULD accept model as first parameter using `super._model`
- You SHOULD use `required` for required parameters
- You SHOULD initialize fields using initializer list

### Error Handling
- You SHOULD use `ResultOk`/`ResultFailed` pattern with switch statements
- You SHOULD handle null cases explicitly

## Widget Implementation

### Basic Structure
- You SHOULD extend `ElementaryWidget` for simple widgets
- You SHOULD extend `BaseWidget` for adaptive implementations
- You SHOULD use factory constructor pattern with `defaultWidgetWMFactory`

### State Management
- You SHOULD use `UnionStateListenableBuilder` for complex states
- You SHOULD use `ValueListenableBuilder` for simple states
- You SHOULD handle loading/error/empty states appropriately

### Adaptive Implementation
- You SHOULD implement both `buildMobile` and `buildDesktop` methods
- You SHOULD use platform-specific widgets and layouts
- You SHOULD organize files with `mobile/` and `desktop/` directories
