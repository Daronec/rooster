# API Layer Implementation

## DTO Implementation

The DTO pattern serializes/deserializes API data using these rules:

### Base Structure
- You SHOULD use `@JsonSerializable(includeIfNull: false)` annotation
- You SHOULD include generated part file (`.g.dart`)
- You SHOULD make all fields final and nullable
- You SHOULD implement const constructors

### Field Rules
- You SHOULD use `@JsonKey` annotation for each field
- You SHOULD specify JSON field name in quotes
- You SHOULD use appropriate `DtoUtils` methods:
  - `readInt` for integers
  - `readString` for strings
  - `readBool` for booleans
  - `readList` for lists
  - `readMap` for maps

### Documentation
- You SHOULD provide class-level docs explaining purpose
- You SHOULD document each field
- You SHOULD include TODO comments for future updates

### JSON Methods
- You SHOULD implement `fromJson` factory method
- You SHOULD implement `toJson` method
- You SHOULD use generated code for serialization
- You SHOULD handle null cases appropriately

## API Service Implementation

API services define contracts for external communication:

### Base Structure
- You SHOULD use Retrofit for API service definitions
- You SHOULD create abstract classes with factory constructors
- You SHOULD include proper documentation

### HTTP Methods
- You SHOULD use appropriate annotations for each HTTP method:
  - `@GET`, `@POST`, `@PUT`, `@DELETE`, `@PATCH`, etc.

### Parameter Annotations
- You SHOULD use appropriate annotations for parameters:
  - `@Path`, `@Query`, `@Body`, `@Header`, etc.

### Method Implementation
- You SHOULD use nullable return types where appropriate
- You SHOULD document each method's purpose

### Best Practices
- You SHOULD NEVER implement error handling in API service
- You SHOULD NEVER use try-catch blocks
- You SHOULD use generated code from `make codegen`

## URL Implementation

URL classes manage API endpoint definitions:

### Base Structure
- You SHOULD create private constructor for URL classes
- You SHOULD use static constants for endpoints
- You SHOULD group related endpoints together

### URL Constants
- You SHOULD use static const for all endpoints
- You SHOULD name constants in camelCase
- You SHOULD start URLs with forward slash

### Documentation
- You SHOULD document each endpoint and its purpose

## API Layer Organization
```
lib/
└──api/
    ├── data/           # DTOs
    └── service/        # API services
        └── feature/    # Feature services
            ├── urls.dart
            └── api.dart
```
