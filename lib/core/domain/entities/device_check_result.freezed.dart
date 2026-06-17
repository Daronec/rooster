// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_check_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceCheckResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCheckResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeviceCheckResult()';
}


}

/// @nodoc
class $DeviceCheckResultCopyWith<$Res>  {
$DeviceCheckResultCopyWith(DeviceCheckResult _, $Res Function(DeviceCheckResult) __);
}


/// Adds pattern-matching-related methods to [DeviceCheckResult].
extension DeviceCheckResultPatterns on DeviceCheckResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeviceCheckSuccessResult value)?  success,TResult Function( DeviceBlockedResult value)?  deviceBlocked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeviceCheckSuccessResult() when success != null:
return success(_that);case DeviceBlockedResult() when deviceBlocked != null:
return deviceBlocked(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeviceCheckSuccessResult value)  success,required TResult Function( DeviceBlockedResult value)  deviceBlocked,}){
final _that = this;
switch (_that) {
case DeviceCheckSuccessResult():
return success(_that);case DeviceBlockedResult():
return deviceBlocked(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeviceCheckSuccessResult value)?  success,TResult? Function( DeviceBlockedResult value)?  deviceBlocked,}){
final _that = this;
switch (_that) {
case DeviceCheckSuccessResult() when success != null:
return success(_that);case DeviceBlockedResult() when deviceBlocked != null:
return deviceBlocked(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String deviceId,  bool inNewUser)?  success,TResult Function( int blockDurationInMinutes)?  deviceBlocked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeviceCheckSuccessResult() when success != null:
return success(_that.deviceId,_that.inNewUser);case DeviceBlockedResult() when deviceBlocked != null:
return deviceBlocked(_that.blockDurationInMinutes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String deviceId,  bool inNewUser)  success,required TResult Function( int blockDurationInMinutes)  deviceBlocked,}) {final _that = this;
switch (_that) {
case DeviceCheckSuccessResult():
return success(_that.deviceId,_that.inNewUser);case DeviceBlockedResult():
return deviceBlocked(_that.blockDurationInMinutes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String deviceId,  bool inNewUser)?  success,TResult? Function( int blockDurationInMinutes)?  deviceBlocked,}) {final _that = this;
switch (_that) {
case DeviceCheckSuccessResult() when success != null:
return success(_that.deviceId,_that.inNewUser);case DeviceBlockedResult() when deviceBlocked != null:
return deviceBlocked(_that.blockDurationInMinutes);case _:
  return null;

}
}

}

/// @nodoc


class DeviceCheckSuccessResult implements DeviceCheckResult {
  const DeviceCheckSuccessResult({required this.deviceId, required this.inNewUser});
  

/// Идентификатор устройства, который присваивает back-end.
 final  String deviceId;
/// Является ли пользователь новым.
 final  bool inNewUser;

/// Create a copy of DeviceCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCheckSuccessResultCopyWith<DeviceCheckSuccessResult> get copyWith => _$DeviceCheckSuccessResultCopyWithImpl<DeviceCheckSuccessResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCheckSuccessResult&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.inNewUser, inNewUser) || other.inNewUser == inNewUser));
}


@override
int get hashCode => Object.hash(runtimeType,deviceId,inNewUser);

@override
String toString() {
  return 'DeviceCheckResult.success(deviceId: $deviceId, inNewUser: $inNewUser)';
}


}

/// @nodoc
abstract mixin class $DeviceCheckSuccessResultCopyWith<$Res> implements $DeviceCheckResultCopyWith<$Res> {
  factory $DeviceCheckSuccessResultCopyWith(DeviceCheckSuccessResult value, $Res Function(DeviceCheckSuccessResult) _then) = _$DeviceCheckSuccessResultCopyWithImpl;
@useResult
$Res call({
 String deviceId, bool inNewUser
});




}
/// @nodoc
class _$DeviceCheckSuccessResultCopyWithImpl<$Res>
    implements $DeviceCheckSuccessResultCopyWith<$Res> {
  _$DeviceCheckSuccessResultCopyWithImpl(this._self, this._then);

  final DeviceCheckSuccessResult _self;
  final $Res Function(DeviceCheckSuccessResult) _then;

/// Create a copy of DeviceCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? inNewUser = null,}) {
  return _then(DeviceCheckSuccessResult(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,inNewUser: null == inNewUser ? _self.inNewUser : inNewUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class DeviceBlockedResult implements DeviceCheckResult {
  const DeviceBlockedResult({required this.blockDurationInMinutes});
  

/// Длительность блокировки в минутах.
 final  int blockDurationInMinutes;

/// Create a copy of DeviceCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceBlockedResultCopyWith<DeviceBlockedResult> get copyWith => _$DeviceBlockedResultCopyWithImpl<DeviceBlockedResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceBlockedResult&&(identical(other.blockDurationInMinutes, blockDurationInMinutes) || other.blockDurationInMinutes == blockDurationInMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,blockDurationInMinutes);

@override
String toString() {
  return 'DeviceCheckResult.deviceBlocked(blockDurationInMinutes: $blockDurationInMinutes)';
}


}

/// @nodoc
abstract mixin class $DeviceBlockedResultCopyWith<$Res> implements $DeviceCheckResultCopyWith<$Res> {
  factory $DeviceBlockedResultCopyWith(DeviceBlockedResult value, $Res Function(DeviceBlockedResult) _then) = _$DeviceBlockedResultCopyWithImpl;
@useResult
$Res call({
 int blockDurationInMinutes
});




}
/// @nodoc
class _$DeviceBlockedResultCopyWithImpl<$Res>
    implements $DeviceBlockedResultCopyWith<$Res> {
  _$DeviceBlockedResultCopyWithImpl(this._self, this._then);

  final DeviceBlockedResult _self;
  final $Res Function(DeviceBlockedResult) _then;

/// Create a copy of DeviceCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blockDurationInMinutes = null,}) {
  return _then(DeviceBlockedResult(
blockDurationInMinutes: null == blockDurationInMinutes ? _self.blockDurationInMinutes : blockDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
