# Persistence Guidelines

## Persistence Architecture

The persistence layer is located in `lib/persistence/` and follows a consistent **interface + implementation** pattern.

### Directory Structure

```
lib/persistence/
  storage/
    app_info_storage/           # Device ID
    biometry_method_storage/    # Biometry usage flag
    calendar_auth_storage/      # Calendar auth status
    config_storage/             # App config (url, proxy)
    contact_positions_storage/  # Cached DTO: Partner positions
    countries_storage/          # Cached DTO: Countries list
    first_launch_storage/       # First launch flag + secure cleanup
    markers_day_storage/        # Cached DTO: Day markers (date-range keyed)
    onboarding_storage/         # Onboarding version
    partner_conditions_storage/ # Cached DTO: Partner conditions
    partner_potential_classes_storage/ # Cached DTO: Partner potential
    phone_input_storage/        # Phone number (with legacy migration)
    pin_code_storage/           # PIN code (secure)
    profile_storage/            # User profile
    theme_storage/              # Theme mode
    tokens_storage/             # Auth tokens (secure)
    tradecodes_storage/         # Cached DTO: Tradecodes
```

## Storage Backends

### SharedPreferences

Used for non-sensitive data:
- App settings (theme, onboarding, config)
- Cached DTOs (countries, partners, tradecodes, etc.)
- User profile (non-sensitive fields)
- Flags and booleans

### FlutterSecureStorage

Used for sensitive data:
- JWT tokens (access + refresh)
- PIN codes
- First launch cleanup

## Interface + Implementation Pattern

### Creating a New Storage Module

Each module has:
1. Interface file: `i_<name>_storage.dart`
2. Implementation file: `<name>_storage_impl.dart` or `<name>_storage.dart`

### Interface Definition

```dart
// lib/persistence/storage/my_feature/i_my_storage.dart

abstract interface class IMyStorage {
  Future<MyDto?> read();
  Future<void> write(MyDto data);
  Future<void> delete();
}
```

### Implementation with SharedPreferences

```dart
// lib/persistence/storage/my_feature/my_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekf_sales/persistence/storage/my_feature/i_my_storage.dart';

final class MyStorage implements IMyStorage {
  final SharedPreferences _prefs;
  static const _key = 'my_feature_key';

  MyStorage(this._prefs);

  @override
  Future<MyDto?> read() async {
    final stored = _prefs.getString(_key);
    if (stored == null) return null;
    return MyDto.fromJson(jsonDecode(stored) as Map<String, dynamic>);
  }

  @override
  Future<void> write(MyDto data) async {
    await _prefs.setString(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<void> delete() async {
    await _prefs.remove(_key);
  }
}
```

### Implementation with Secure Storage

```dart
// lib/persistence/storage/my_feature/my_secure_storage_impl.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ekf_sales/persistence/storage/my_feature/i_my_secure_storage.dart';

final class MySecureStorageImpl implements IMySecureStorage {
  final FlutterSecureStorage _secureStorage;
  static const _key = 'my_secure_key';

  MySecureStorageImpl(this._secureStorage);

  @override
  Future<String?> read() async {
    return await _secureStorage.read(key: _key);
  }

  @override
  Future<void> write(String data) async {
    await _secureStorage.write(key: _key, value: data);
  }

  @override
  Future<void> delete() async {
    await _secureStorage.delete(key: _key);
  }
}
```

## DTO Caching Pattern

### When to Cache

Cache DTOs that:
- Are fetched from API infrequently
- Are used across multiple screens/features
- Don't change frequently (reference data)

### Cached DTOs

- `PartnerPositionsDto` — Partner positions
- `CountryDto` — Countries list
- `PartnerConditionsDto` — Partner conditions
- `PartnerPotentialClassesDto` — Partner potential classes
- `TradecodesResponseDto` — Tradecodes
- `MarkerDayDto` — Day markers (date-range keyed)

### Caching Pattern

```dart
// Write
await _prefs.setString(key, jsonEncode(dto.toJson()));

// Read
final stored = _prefs.getString(key);
if (stored == null) return null;
return Dto.fromJson(jsonDecode(stored) as Map<String, dynamic>);
```

### Composite Keys

For date-range based caching (e.g., markers):
```dart
static String _generateKey(DateTime start, DateTime end) {
  return 'marker_days_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
}
```

## Secure Storage Keys

| Module | Key | Purpose |
|--------|-----|---------|
| Token Storage | `app_auth_token` | JWT access + refresh tokens (JSON) |
| PIN Code | `pin_code` | User PIN code (plain string) |

## DI Registration

Storage dependencies are injected via scopes:

```dart
// In AppScope or feature scope
final storage = MyStorage(sharedPreferences);
// or
final secureStorage = MySecureStorageImpl(FlutterSecureStorage());
```

## Important Notes

- You SHOULD NEVER store sensitive data (tokens, PINs) in SharedPreferences
- You SHOULD use `jsonEncode`/`jsonDecode` for DTO serialization
- You SHOULD use `json_annotation` + `json_serializable` for DTOs stored in persistence
- You SHOULD provide interface for testability (mock storage in tests)
- You SHOULD handle null returns gracefully from `read()` methods

## Cache Limitations

- There is NO TTL/expiration mechanism for cached data
- There is NO automatic cache invalidation
- Cached data persists until explicitly cleared via `delete()`
- Consider invalidating cache in the repository layer when data changes

## Persistence Best Practices

- You SHOULD follow the interface + implementation pattern for all storage modules
- You SHOULD use SharedPreferences for non-sensitive data
- You SHOULD use FlutterSecureStorage for tokens, PIN codes, and sensitive data
- You SHOULD use json_annotation + json_serializable for stored DTOs
- You SHOULD handle null returns from read() methods gracefully
- You SHOULD provide interfaces for testability
- You SHOULD document storage keys as constants
- You SHOULD NOT mix secure and non-sensitive data in the same storage module
- You SHOULD clear secure storage on first app launch (see FirstLaunchStorage)
