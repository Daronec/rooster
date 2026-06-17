// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_information_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceInformationEntity {

 DeviceType? get os; String get device; String? get osVersion;
/// Create a copy of DeviceInformationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInformationEntityCopyWith<DeviceInformationEntity> get copyWith => _$DeviceInformationEntityCopyWithImpl<DeviceInformationEntity>(this as DeviceInformationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInformationEntity&&(identical(other.os, os) || other.os == os)&&(identical(other.device, device) || other.device == device)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion));
}


@override
int get hashCode => Object.hash(runtimeType,os,device,osVersion);

@override
String toString() {
  return 'DeviceInformationEntity(os: $os, device: $device, osVersion: $osVersion)';
}


}

/// @nodoc
abstract mixin class $DeviceInformationEntityCopyWith<$Res>  {
  factory $DeviceInformationEntityCopyWith(DeviceInformationEntity value, $Res Function(DeviceInformationEntity) _then) = _$DeviceInformationEntityCopyWithImpl;
@useResult
$Res call({
 DeviceType? os, String device, String? osVersion
});




}
/// @nodoc
class _$DeviceInformationEntityCopyWithImpl<$Res>
    implements $DeviceInformationEntityCopyWith<$Res> {
  _$DeviceInformationEntityCopyWithImpl(this._self, this._then);

  final DeviceInformationEntity _self;
  final $Res Function(DeviceInformationEntity) _then;

/// Create a copy of DeviceInformationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? os = freezed,Object? device = null,Object? osVersion = freezed,}) {
  return _then(_self.copyWith(
os: freezed == os ? _self.os : os // ignore: cast_nullable_to_non_nullable
as DeviceType?,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,osVersion: freezed == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceInformationEntity].
extension DeviceInformationEntityPatterns on DeviceInformationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceInformationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceInformationEntity() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceInformationEntity value)  $default,){
final _that = this;
switch (_that) {
case _DeviceInformationEntity():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceInformationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceInformationEntity() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceType? os,  String device,  String? osVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInformationEntity() when $default != null:
return $default(_that.os,_that.device,_that.osVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceType? os,  String device,  String? osVersion)  $default,) {final _that = this;
switch (_that) {
case _DeviceInformationEntity():
return $default(_that.os,_that.device,_that.osVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceType? os,  String device,  String? osVersion)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInformationEntity() when $default != null:
return $default(_that.os,_that.device,_that.osVersion);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceInformationEntity implements DeviceInformationEntity {
  const _DeviceInformationEntity({required this.os, required this.device, required this.osVersion});
  

@override final  DeviceType? os;
@override final  String device;
@override final  String? osVersion;

/// Create a copy of DeviceInformationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInformationEntityCopyWith<_DeviceInformationEntity> get copyWith => __$DeviceInformationEntityCopyWithImpl<_DeviceInformationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInformationEntity&&(identical(other.os, os) || other.os == os)&&(identical(other.device, device) || other.device == device)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion));
}


@override
int get hashCode => Object.hash(runtimeType,os,device,osVersion);

@override
String toString() {
  return 'DeviceInformationEntity(os: $os, device: $device, osVersion: $osVersion)';
}


}

/// @nodoc
abstract mixin class _$DeviceInformationEntityCopyWith<$Res> implements $DeviceInformationEntityCopyWith<$Res> {
  factory _$DeviceInformationEntityCopyWith(_DeviceInformationEntity value, $Res Function(_DeviceInformationEntity) _then) = __$DeviceInformationEntityCopyWithImpl;
@override @useResult
$Res call({
 DeviceType? os, String device, String? osVersion
});




}
/// @nodoc
class __$DeviceInformationEntityCopyWithImpl<$Res>
    implements _$DeviceInformationEntityCopyWith<$Res> {
  __$DeviceInformationEntityCopyWithImpl(this._self, this._then);

  final _DeviceInformationEntity _self;
  final $Res Function(_DeviceInformationEntity) _then;

/// Create a copy of DeviceInformationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? os = freezed,Object? device = null,Object? osVersion = freezed,}) {
  return _then(_DeviceInformationEntity(
os: freezed == os ? _self.os : os // ignore: cast_nullable_to_non_nullable
as DeviceType?,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,osVersion: freezed == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
