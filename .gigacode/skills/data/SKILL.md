# Data Layer Implementation

The data layer handles data operations and transformations following clean architecture.

## Repository Implementation

### Base Structure
- You SHOULD extend `BaseRepository` for all repository interfaces
- You SHOULD use abstract interface class declaration
- You SHOULD place interfaces in the domain layer
- You SHOULD ONLY use domain entities in interfaces
- You SHOULD NEVER use DTOs or other data layer objects
- All return types and parameters MUST be domain entities

### Operation Types
- You SHOULD use `ApiOperation<T>` for API calls without specific error handling
- You SHOULD use `RequestOperation<T, Failure>` for specific failure cases
- `T` MUST always be a domain entity or primitive type
- You SHOULD wrap all API calls with `makeCall()`

### Dependencies
- You SHOULD inject required dependencies (API service, converter, etc.)
- You SHOULD declare dependencies as private final fields
- You SHOULD prefix field names with underscore (e.g., `_api`)

### Method Implementation
- You SHOULD return appropriate operation type
- You SHOULD use `makeCall()` wrapper for API calls
- You SHOULD convert API responses to domain entities
- You SHOULD handle null cases appropriately

## Converter Implementation

### Base Rules
- You SHOULD NEVER use the bang (!) operator
- You SHOULD always provide default values for nullable fields
- You SHOULD use `ConverterToAndFrom` and implement both converters
- You SHOULD use separate converters for nested entities

### Implementation Structure
- You SHOULD extend `ConverterToAndFrom<Entity, Dto>`
- You SHOULD use const constructors where possible
- You SHOULD implement null-safe conversion

## Data Layer Organization
```
data/
├── converters/     # Data transformations
└── repositories/   # Repository implementations
```

## Error Handling
- You SHOULD use appropriate operation types for different scenarios
- You SHOULD provide meaningful error messages
- You SHOULD implement null-safe conversions
- You SHOULD provide default values for nullable fields
