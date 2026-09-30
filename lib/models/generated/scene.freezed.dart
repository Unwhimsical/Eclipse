// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scene {

 int get id; String get name; SceneTriggerType get triggerType; String? get ssid; int? get targetProfileId; Mode? get mode; String? get targetProxy; int get order;
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneCopyWith<Scene> get copyWith => _$SceneCopyWithImpl<Scene>(this as Scene, _$identity);

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Scene;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scene&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.triggerType, _this.triggerType) || other.triggerType == _this.triggerType)&&(identical(other.ssid, _this.ssid) || other.ssid == _this.ssid)&&(identical(other.targetProfileId, _this.targetProfileId) || other.targetProfileId == _this.targetProfileId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.targetProxy, _this.targetProxy) || other.targetProxy == _this.targetProxy)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Scene;
  return Object.hash(runtimeType,_this.id,_this.name,_this.triggerType,_this.ssid,_this.targetProfileId,_this.mode,_this.targetProxy,_this.order);
}

@override
String toString() {
  final _this = this as Scene;
  return 'Scene(id: ${_this.id}, name: ${_this.name}, triggerType: ${_this.triggerType}, ssid: ${_this.ssid}, targetProfileId: ${_this.targetProfileId}, mode: ${_this.mode}, targetProxy: ${_this.targetProxy}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $SceneCopyWith<$Res>  {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) _then) = _$SceneCopyWithImpl;
@useResult
$Res call({
 int id, String name, SceneTriggerType triggerType, String? ssid, int? targetProfileId, Mode? mode, String? targetProxy, int order
});




}
/// @nodoc
class _$SceneCopyWithImpl<$Res>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._self, this._then);

  final Scene _self;
  final $Res Function(Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? triggerType = null,Object? ssid = freezed,Object? targetProfileId = freezed,Object? mode = freezed,Object? targetProxy = freezed,Object? order = null,}) {
  return _then(Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerType: null == triggerType ? _self.triggerType : triggerType // ignore: cast_nullable_to_non_nullable
as SceneTriggerType,ssid: freezed == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String?,targetProfileId: freezed == targetProfileId ? _self.targetProfileId : targetProfileId // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode?,targetProxy: freezed == targetProxy ? _self.targetProxy : targetProxy // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Scene].
extension ScenePatterns on Scene {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scene value)  $default,){
final _that = this;
switch (_that) {
case _Scene():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scene value)?  $default,){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  SceneTriggerType triggerType,  String? ssid,  int? targetProfileId,  Mode? mode,  String? targetProxy,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.triggerType,_that.ssid,_that.targetProfileId,_that.mode,_that.targetProxy,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  SceneTriggerType triggerType,  String? ssid,  int? targetProfileId,  Mode? mode,  String? targetProxy,  int order)  $default,) {final _that = this;
switch (_that) {
case _Scene():
return $default(_that.id,_that.name,_that.triggerType,_that.ssid,_that.targetProfileId,_that.mode,_that.targetProxy,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  SceneTriggerType triggerType,  String? ssid,  int? targetProfileId,  Mode? mode,  String? targetProxy,  int order)?  $default,) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.triggerType,_that.ssid,_that.targetProfileId,_that.mode,_that.targetProxy,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scene implements Scene {
  const _Scene({required this.id, required this.name, required this.triggerType, this.ssid, this.targetProfileId, this.mode, this.targetProxy, this.order = 0});
  factory _Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

@override final  int id;
@override final  String name;
@override final  SceneTriggerType triggerType;
@override final  String? ssid;
@override final  int? targetProfileId;
@override final  Mode? mode;
@override final  String? targetProxy;
@override@JsonKey() final  int order;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneCopyWith<_Scene> get copyWith => __$SceneCopyWithImpl<_Scene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.triggerType, triggerType) || other.triggerType == triggerType)&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.targetProfileId, targetProfileId) || other.targetProfileId == targetProfileId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.targetProxy, targetProxy) || other.targetProxy == targetProxy)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,triggerType,ssid,targetProfileId,mode,targetProxy,order);
}

@override
String toString() {
    return 'Scene(id: $id, name: $name, triggerType: $triggerType, ssid: $ssid, targetProfileId: $targetProfileId, mode: $mode, targetProxy: $targetProxy, order: $order)';
}


}

/// @nodoc
abstract mixin class _$SceneCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$SceneCopyWith(_Scene value, $Res Function(_Scene) _then) = __$SceneCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, SceneTriggerType triggerType, String? ssid, int? targetProfileId, Mode? mode, String? targetProxy, int order
});




}
/// @nodoc
class __$SceneCopyWithImpl<$Res>
    implements _$SceneCopyWith<$Res> {
  __$SceneCopyWithImpl(this._self, this._then);

  final _Scene _self;
  final $Res Function(_Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? triggerType = null,Object? ssid = freezed,Object? targetProfileId = freezed,Object? mode = freezed,Object? targetProxy = freezed,Object? order = null,}) {
  return _then(_Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerType: null == triggerType ? _self.triggerType : triggerType // ignore: cast_nullable_to_non_nullable
as SceneTriggerType,ssid: freezed == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String?,targetProfileId: freezed == targetProfileId ? _self.targetProfileId : targetProfileId // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode?,targetProxy: freezed == targetProxy ? _self.targetProxy : targetProxy // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
