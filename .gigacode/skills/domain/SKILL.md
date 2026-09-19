# Domain Layer Implementation

The domain layer contains core business logic and entities.

## Entity Implementation

### Base Structure
- You SHOULD use Freezed for immutable data classes
- You SHOULD make class abstract with `@freezed` annotation
- You SHOULD mixin generated class with `_$ClassName`
- You SHOULD implement private constructor
- You SHOULD use factory constructor for instantiation

### Field Rules
- You SHOULD use `required` keyword for required fields
- You SHOULD use nullable types (`Type?`) for optional fields
- You SHOULD document all fields
- You SHOULD keep fields immutable

### Documentation Requirements
- You SHOULD include class-level documentation
- You SHOULD document all fields
- You SHOULD format TODOs as `// TODO(someone): description`

### Code Generation
- You SHOULD use `make codegen` for code generation
- You SHOULD NEVER manually implement generated functionality

### Best Practices
- You SHOULD use immutable fields
- You SHOULD keep class focused on single responsibility
- You SHOULD handle null safety properly
- You SHOULD avoid business logic in entities

## Repository Interface Implementation

### Base Interface Rules
- You MUST implement `IBaseRepository` 
- You MUST use abstract interface class declaration
- You MUST place interfaces in the domain layer
- You MUST ONLY use domain entities in interfaces
- You SHOULD NEVER use DTOs or data layer objects

### Operation Types
- You SHOULD use `ApiOperation<T>` for API calls
- You SHOULD use `RequestOperation<T, Failure>` for specific failures
- `T` MUST be a domain entity or primitive type

### Method Documentation
- You SHOULD document each method's purpose
- You SHOULD document parameters and return types
- You SHOULD document error cases
- You SHOULD use triple-slash comments

## Domain Layer Organization
```
domain/
├── entities/     # Business entities
└── repositories/ # Repository interfaces
```
