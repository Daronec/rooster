# Project Architecture

## Core Principles

- You SHOULD NEVER implement generated files manually
- You SHOULD use `make codegen` to generate all needed files
- You SHOULD follow example patterns in `lib/example` directory for all implementations

## Example Components

- **Feature Structure** (`lib/example/features/example/`)
  - `domain/` - Business logic and domain models
  - `data/` - Data layer implementation
  - `presentation/` - UI components and state management
  - `di/` - Dependency injection setup

- **Syntax Examples** (`lib/example/syntax/`)
  - `pattern_matching.dart` - Shows pattern matching techniques
  - `interface.dart` - Demonstrates interface implementation patterns

## Scope Implementation

- You SHOULD implement feature-level dependencies using scope-based dependency injection
- Each feature SHOULD have its own scope following the pattern in `lib/example/features/example/di/example_scope.dart`
