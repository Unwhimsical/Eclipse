// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInfo {

 int get upload; int get download; int get total; int get expire;
/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith => _$SubscriptionInfoCopyWithImpl<SubscriptionInfo>(this as SubscriptionInfo, _$identity);

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as SubscriptionInfo;
  return 'SubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
}


}

/// @nodoc
abstract mixin class $SubscriptionInfoCopyWith<$Res>  {
  factory $SubscriptionInfoCopyWith(SubscriptionInfo value, $Res Function(SubscriptionInfo) _then) = _$SubscriptionInfoCopyWithImpl;
@useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final SubscriptionInfo _self;
  final $Res Function(SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionInfo].
extension SubscriptionInfoPatterns on SubscriptionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int upload,  int download,  int total,  int expire)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInfo implements SubscriptionInfo {
  const _SubscriptionInfo({this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});
  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) => _$SubscriptionInfoFromJson(json);

@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override@JsonKey() final  int total;
@override@JsonKey() final  int expire;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInfoCopyWith<_SubscriptionInfo> get copyWith => __$SubscriptionInfoCopyWithImpl<_SubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

@override
String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInfoCopyWith<$Res> implements $SubscriptionInfoCopyWith<$Res> {
  factory _$SubscriptionInfoCopyWith(_SubscriptionInfo value, $Res Function(_SubscriptionInfo) _then) = __$SubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class __$SubscriptionInfoCopyWithImpl<$Res>
    implements _$SubscriptionInfoCopyWith<$Res> {
  __$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final _SubscriptionInfo _self;
  final $Res Function(_SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GeneralSettings {

 List<String> get dnsServers; List<String> get fallbackDnsServers; List<String> get directDnsServers; List<String> get skipProxy; List<String> get tunExcludedRoutes; List<String> get tunIncludedRoutes; bool? get ipv6; bool? get preferIpv6; bool? get privateIpAnswer; bool? get alwaysRealIp; String? get include;
/// Create a copy of GeneralSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneralSettingsCopyWith<GeneralSettings> get copyWith => _$GeneralSettingsCopyWithImpl<GeneralSettings>(this as GeneralSettings, _$identity);

  /// Serializes this GeneralSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GeneralSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneralSettings&&const DeepCollectionEquality().equals(other.dnsServers, _this.dnsServers)&&const DeepCollectionEquality().equals(other.fallbackDnsServers, _this.fallbackDnsServers)&&const DeepCollectionEquality().equals(other.directDnsServers, _this.directDnsServers)&&const DeepCollectionEquality().equals(other.skipProxy, _this.skipProxy)&&const DeepCollectionEquality().equals(other.tunExcludedRoutes, _this.tunExcludedRoutes)&&const DeepCollectionEquality().equals(other.tunIncludedRoutes, _this.tunIncludedRoutes)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.preferIpv6, _this.preferIpv6) || other.preferIpv6 == _this.preferIpv6)&&(identical(other.privateIpAnswer, _this.privateIpAnswer) || other.privateIpAnswer == _this.privateIpAnswer)&&(identical(other.alwaysRealIp, _this.alwaysRealIp) || other.alwaysRealIp == _this.alwaysRealIp)&&(identical(other.include, _this.include) || other.include == _this.include));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GeneralSettings;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.dnsServers),const DeepCollectionEquality().hash(_this.fallbackDnsServers),const DeepCollectionEquality().hash(_this.directDnsServers),const DeepCollectionEquality().hash(_this.skipProxy),const DeepCollectionEquality().hash(_this.tunExcludedRoutes),const DeepCollectionEquality().hash(_this.tunIncludedRoutes),_this.ipv6,_this.preferIpv6,_this.privateIpAnswer,_this.alwaysRealIp,_this.include);
}

@override
String toString() {
  final _this = this as GeneralSettings;
  return 'GeneralSettings(dnsServers: ${_this.dnsServers}, fallbackDnsServers: ${_this.fallbackDnsServers}, directDnsServers: ${_this.directDnsServers}, skipProxy: ${_this.skipProxy}, tunExcludedRoutes: ${_this.tunExcludedRoutes}, tunIncludedRoutes: ${_this.tunIncludedRoutes}, ipv6: ${_this.ipv6}, preferIpv6: ${_this.preferIpv6}, privateIpAnswer: ${_this.privateIpAnswer}, alwaysRealIp: ${_this.alwaysRealIp}, include: ${_this.include})';
}


}

/// @nodoc
abstract mixin class $GeneralSettingsCopyWith<$Res>  {
  factory $GeneralSettingsCopyWith(GeneralSettings value, $Res Function(GeneralSettings) _then) = _$GeneralSettingsCopyWithImpl;
@useResult
$Res call({
 List<String> dnsServers, List<String> fallbackDnsServers, List<String> directDnsServers, List<String> skipProxy, List<String> tunExcludedRoutes, List<String> tunIncludedRoutes, bool? ipv6, bool? preferIpv6, bool? privateIpAnswer, bool? alwaysRealIp, String? include
});




}
/// @nodoc
class _$GeneralSettingsCopyWithImpl<$Res>
    implements $GeneralSettingsCopyWith<$Res> {
  _$GeneralSettingsCopyWithImpl(this._self, this._then);

  final GeneralSettings _self;
  final $Res Function(GeneralSettings) _then;

/// Create a copy of GeneralSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dnsServers = null,Object? fallbackDnsServers = null,Object? directDnsServers = null,Object? skipProxy = null,Object? tunExcludedRoutes = null,Object? tunIncludedRoutes = null,Object? ipv6 = freezed,Object? preferIpv6 = freezed,Object? privateIpAnswer = freezed,Object? alwaysRealIp = freezed,Object? include = freezed,}) {
  return _then(GeneralSettings(
dnsServers: null == dnsServers ? _self.dnsServers : dnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackDnsServers: null == fallbackDnsServers ? _self.fallbackDnsServers : fallbackDnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,directDnsServers: null == directDnsServers ? _self.directDnsServers : directDnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,skipProxy: null == skipProxy ? _self.skipProxy : skipProxy // ignore: cast_nullable_to_non_nullable
as List<String>,tunExcludedRoutes: null == tunExcludedRoutes ? _self.tunExcludedRoutes : tunExcludedRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,tunIncludedRoutes: null == tunIncludedRoutes ? _self.tunIncludedRoutes : tunIncludedRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,ipv6: freezed == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool?,preferIpv6: freezed == preferIpv6 ? _self.preferIpv6 : preferIpv6 // ignore: cast_nullable_to_non_nullable
as bool?,privateIpAnswer: freezed == privateIpAnswer ? _self.privateIpAnswer : privateIpAnswer // ignore: cast_nullable_to_non_nullable
as bool?,alwaysRealIp: freezed == alwaysRealIp ? _self.alwaysRealIp : alwaysRealIp // ignore: cast_nullable_to_non_nullable
as bool?,include: freezed == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneralSettings].
extension GeneralSettingsPatterns on GeneralSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneralSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneralSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneralSettings value)  $default,){
final _that = this;
switch (_that) {
case _GeneralSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneralSettings value)?  $default,){
final _that = this;
switch (_that) {
case _GeneralSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> dnsServers,  List<String> fallbackDnsServers,  List<String> directDnsServers,  List<String> skipProxy,  List<String> tunExcludedRoutes,  List<String> tunIncludedRoutes,  bool? ipv6,  bool? preferIpv6,  bool? privateIpAnswer,  bool? alwaysRealIp,  String? include)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneralSettings() when $default != null:
return $default(_that.dnsServers,_that.fallbackDnsServers,_that.directDnsServers,_that.skipProxy,_that.tunExcludedRoutes,_that.tunIncludedRoutes,_that.ipv6,_that.preferIpv6,_that.privateIpAnswer,_that.alwaysRealIp,_that.include);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> dnsServers,  List<String> fallbackDnsServers,  List<String> directDnsServers,  List<String> skipProxy,  List<String> tunExcludedRoutes,  List<String> tunIncludedRoutes,  bool? ipv6,  bool? preferIpv6,  bool? privateIpAnswer,  bool? alwaysRealIp,  String? include)  $default,) {final _that = this;
switch (_that) {
case _GeneralSettings():
return $default(_that.dnsServers,_that.fallbackDnsServers,_that.directDnsServers,_that.skipProxy,_that.tunExcludedRoutes,_that.tunIncludedRoutes,_that.ipv6,_that.preferIpv6,_that.privateIpAnswer,_that.alwaysRealIp,_that.include);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> dnsServers,  List<String> fallbackDnsServers,  List<String> directDnsServers,  List<String> skipProxy,  List<String> tunExcludedRoutes,  List<String> tunIncludedRoutes,  bool? ipv6,  bool? preferIpv6,  bool? privateIpAnswer,  bool? alwaysRealIp,  String? include)?  $default,) {final _that = this;
switch (_that) {
case _GeneralSettings() when $default != null:
return $default(_that.dnsServers,_that.fallbackDnsServers,_that.directDnsServers,_that.skipProxy,_that.tunExcludedRoutes,_that.tunIncludedRoutes,_that.ipv6,_that.preferIpv6,_that.privateIpAnswer,_that.alwaysRealIp,_that.include);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneralSettings implements GeneralSettings {
  const _GeneralSettings({ List<String> dnsServers = const [],  List<String> fallbackDnsServers = const [],  List<String> directDnsServers = const [],  List<String> skipProxy = const [],  List<String> tunExcludedRoutes = const [],  List<String> tunIncludedRoutes = const [], this.ipv6, this.preferIpv6, this.privateIpAnswer, this.alwaysRealIp, this.include}): _dnsServers = dnsServers,_fallbackDnsServers = fallbackDnsServers,_directDnsServers = directDnsServers,_skipProxy = skipProxy,_tunExcludedRoutes = tunExcludedRoutes,_tunIncludedRoutes = tunIncludedRoutes;
  factory _GeneralSettings.fromJson(Map<String, dynamic> json) => _$GeneralSettingsFromJson(json);

 final  List<String> _dnsServers;
@override@JsonKey() List<String> get dnsServers {
  if (_dnsServers is EqualUnmodifiableListView) return _dnsServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dnsServers);
}

 final  List<String> _fallbackDnsServers;
@override@JsonKey() List<String> get fallbackDnsServers {
  if (_fallbackDnsServers is EqualUnmodifiableListView) return _fallbackDnsServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fallbackDnsServers);
}

 final  List<String> _directDnsServers;
@override@JsonKey() List<String> get directDnsServers {
  if (_directDnsServers is EqualUnmodifiableListView) return _directDnsServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directDnsServers);
}

 final  List<String> _skipProxy;
@override@JsonKey() List<String> get skipProxy {
  if (_skipProxy is EqualUnmodifiableListView) return _skipProxy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipProxy);
}

 final  List<String> _tunExcludedRoutes;
@override@JsonKey() List<String> get tunExcludedRoutes {
  if (_tunExcludedRoutes is EqualUnmodifiableListView) return _tunExcludedRoutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunExcludedRoutes);
}

 final  List<String> _tunIncludedRoutes;
@override@JsonKey() List<String> get tunIncludedRoutes {
  if (_tunIncludedRoutes is EqualUnmodifiableListView) return _tunIncludedRoutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunIncludedRoutes);
}

@override final  bool? ipv6;
@override final  bool? preferIpv6;
@override final  bool? privateIpAnswer;
@override final  bool? alwaysRealIp;
@override final  String? include;

/// Create a copy of GeneralSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneralSettingsCopyWith<_GeneralSettings> get copyWith => __$GeneralSettingsCopyWithImpl<_GeneralSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneralSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneralSettings&&const DeepCollectionEquality().equals(other.dnsServers, _dnsServers)&&const DeepCollectionEquality().equals(other.fallbackDnsServers, _fallbackDnsServers)&&const DeepCollectionEquality().equals(other.directDnsServers, _directDnsServers)&&const DeepCollectionEquality().equals(other.skipProxy, _skipProxy)&&const DeepCollectionEquality().equals(other.tunExcludedRoutes, _tunExcludedRoutes)&&const DeepCollectionEquality().equals(other.tunIncludedRoutes, _tunIncludedRoutes)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.preferIpv6, preferIpv6) || other.preferIpv6 == preferIpv6)&&(identical(other.privateIpAnswer, privateIpAnswer) || other.privateIpAnswer == privateIpAnswer)&&(identical(other.alwaysRealIp, alwaysRealIp) || other.alwaysRealIp == alwaysRealIp)&&(identical(other.include, include) || other.include == include));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_dnsServers),const DeepCollectionEquality().hash(_fallbackDnsServers),const DeepCollectionEquality().hash(_directDnsServers),const DeepCollectionEquality().hash(_skipProxy),const DeepCollectionEquality().hash(_tunExcludedRoutes),const DeepCollectionEquality().hash(_tunIncludedRoutes),ipv6,preferIpv6,privateIpAnswer,alwaysRealIp,include);
}

@override
String toString() {
    return 'GeneralSettings(dnsServers: $dnsServers, fallbackDnsServers: $fallbackDnsServers, directDnsServers: $directDnsServers, skipProxy: $skipProxy, tunExcludedRoutes: $tunExcludedRoutes, tunIncludedRoutes: $tunIncludedRoutes, ipv6: $ipv6, preferIpv6: $preferIpv6, privateIpAnswer: $privateIpAnswer, alwaysRealIp: $alwaysRealIp, include: $include)';
}


}

/// @nodoc
abstract mixin class _$GeneralSettingsCopyWith<$Res> implements $GeneralSettingsCopyWith<$Res> {
  factory _$GeneralSettingsCopyWith(_GeneralSettings value, $Res Function(_GeneralSettings) _then) = __$GeneralSettingsCopyWithImpl;
@override @useResult
$Res call({
 List<String> dnsServers, List<String> fallbackDnsServers, List<String> directDnsServers, List<String> skipProxy, List<String> tunExcludedRoutes, List<String> tunIncludedRoutes, bool? ipv6, bool? preferIpv6, bool? privateIpAnswer, bool? alwaysRealIp, String? include
});




}
/// @nodoc
class __$GeneralSettingsCopyWithImpl<$Res>
    implements _$GeneralSettingsCopyWith<$Res> {
  __$GeneralSettingsCopyWithImpl(this._self, this._then);

  final _GeneralSettings _self;
  final $Res Function(_GeneralSettings) _then;

/// Create a copy of GeneralSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dnsServers = null,Object? fallbackDnsServers = null,Object? directDnsServers = null,Object? skipProxy = null,Object? tunExcludedRoutes = null,Object? tunIncludedRoutes = null,Object? ipv6 = freezed,Object? preferIpv6 = freezed,Object? privateIpAnswer = freezed,Object? alwaysRealIp = freezed,Object? include = freezed,}) {
  return _then(_GeneralSettings(
dnsServers: null == dnsServers ? _self._dnsServers : dnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackDnsServers: null == fallbackDnsServers ? _self._fallbackDnsServers : fallbackDnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,directDnsServers: null == directDnsServers ? _self._directDnsServers : directDnsServers // ignore: cast_nullable_to_non_nullable
as List<String>,skipProxy: null == skipProxy ? _self._skipProxy : skipProxy // ignore: cast_nullable_to_non_nullable
as List<String>,tunExcludedRoutes: null == tunExcludedRoutes ? _self._tunExcludedRoutes : tunExcludedRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,tunIncludedRoutes: null == tunIncludedRoutes ? _self._tunIncludedRoutes : tunIncludedRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,ipv6: freezed == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool?,preferIpv6: freezed == preferIpv6 ? _self.preferIpv6 : preferIpv6 // ignore: cast_nullable_to_non_nullable
as bool?,privateIpAnswer: freezed == privateIpAnswer ? _self.privateIpAnswer : privateIpAnswer // ignore: cast_nullable_to_non_nullable
as bool?,alwaysRealIp: freezed == alwaysRealIp ? _self.alwaysRealIp : alwaysRealIp // ignore: cast_nullable_to_non_nullable
as bool?,include: freezed == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Profile {

 int get id; String get label; String? get currentGroupName; String get url; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; bool get autoUpdate; Map<String, String> get selectedMap; Set<String> get unfoldSet; Map<String, String> get hosts; List<String> get urlRewrites; List<String> get headerRewrites; List<String> get mapLocal; List<String> get bodyRewrites; bool get mitmEnabled; List<String> get mitmHostnames; Map<String, String> get proxyChains; GeneralSettings get generalSettings; OverwriteType get overwriteType; int? get scriptId; String? get matchTarget; int? get order; String? get frontProxyId; bool get compatibilityMode; bool get disableStun;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.currentGroupName, _this.currentGroupName) || other.currentGroupName == _this.currentGroupName)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&(identical(other.autoUpdateDuration, _this.autoUpdateDuration) || other.autoUpdateDuration == _this.autoUpdateDuration)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&(identical(other.autoUpdate, _this.autoUpdate) || other.autoUpdate == _this.autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _this.unfoldSet)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts)&&const DeepCollectionEquality().equals(other.urlRewrites, _this.urlRewrites)&&const DeepCollectionEquality().equals(other.headerRewrites, _this.headerRewrites)&&const DeepCollectionEquality().equals(other.mapLocal, _this.mapLocal)&&const DeepCollectionEquality().equals(other.bodyRewrites, _this.bodyRewrites)&&(identical(other.mitmEnabled, _this.mitmEnabled) || other.mitmEnabled == _this.mitmEnabled)&&const DeepCollectionEquality().equals(other.mitmHostnames, _this.mitmHostnames)&&const DeepCollectionEquality().equals(other.proxyChains, _this.proxyChains)&&(identical(other.generalSettings, _this.generalSettings) || other.generalSettings == _this.generalSettings)&&(identical(other.overwriteType, _this.overwriteType) || other.overwriteType == _this.overwriteType)&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId)&&(identical(other.matchTarget, _this.matchTarget) || other.matchTarget == _this.matchTarget)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.frontProxyId, _this.frontProxyId) || other.frontProxyId == _this.frontProxyId)&&(identical(other.compatibilityMode, _this.compatibilityMode) || other.compatibilityMode == _this.compatibilityMode)&&(identical(other.disableStun, _this.disableStun) || other.disableStun == _this.disableStun));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hashAll([runtimeType,_this.id,_this.label,_this.currentGroupName,_this.url,_this.lastUpdateDate,_this.autoUpdateDuration,_this.subscriptionInfo,_this.autoUpdate,const DeepCollectionEquality().hash(_this.selectedMap),const DeepCollectionEquality().hash(_this.unfoldSet),const DeepCollectionEquality().hash(_this.hosts),const DeepCollectionEquality().hash(_this.urlRewrites),const DeepCollectionEquality().hash(_this.headerRewrites),const DeepCollectionEquality().hash(_this.mapLocal),const DeepCollectionEquality().hash(_this.bodyRewrites),_this.mitmEnabled,const DeepCollectionEquality().hash(_this.mitmHostnames),const DeepCollectionEquality().hash(_this.proxyChains),_this.generalSettings,_this.overwriteType,_this.scriptId,_this.matchTarget,_this.order,_this.frontProxyId,_this.compatibilityMode,_this.disableStun]);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, label: ${_this.label}, currentGroupName: ${_this.currentGroupName}, url: ${_this.url}, lastUpdateDate: ${_this.lastUpdateDate}, autoUpdateDuration: ${_this.autoUpdateDuration}, subscriptionInfo: ${_this.subscriptionInfo}, autoUpdate: ${_this.autoUpdate}, selectedMap: ${_this.selectedMap}, unfoldSet: ${_this.unfoldSet}, hosts: ${_this.hosts}, urlRewrites: ${_this.urlRewrites}, headerRewrites: ${_this.headerRewrites}, mapLocal: ${_this.mapLocal}, bodyRewrites: ${_this.bodyRewrites}, mitmEnabled: ${_this.mitmEnabled}, mitmHostnames: ${_this.mitmHostnames}, proxyChains: ${_this.proxyChains}, generalSettings: ${_this.generalSettings}, overwriteType: ${_this.overwriteType}, scriptId: ${_this.scriptId}, matchTarget: ${_this.matchTarget}, order: ${_this.order}, frontProxyId: ${_this.frontProxyId}, compatibilityMode: ${_this.compatibilityMode}, disableStun: ${_this.disableStun})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 int id, String label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, Map<String, String> hosts, List<String> urlRewrites, List<String> headerRewrites, List<String> mapLocal, List<String> bodyRewrites, bool mitmEnabled, List<String> mitmHostnames, Map<String, String> proxyChains, GeneralSettings generalSettings, OverwriteType overwriteType, int? scriptId, String? matchTarget, int? order, String? frontProxyId, bool compatibilityMode, bool disableStun
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;$GeneralSettingsCopyWith<$Res> get generalSettings;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? hosts = null,Object? urlRewrites = null,Object? headerRewrites = null,Object? mapLocal = null,Object? bodyRewrites = null,Object? mitmEnabled = null,Object? mitmHostnames = null,Object? proxyChains = null,Object? generalSettings = null,Object? overwriteType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,Object? frontProxyId = freezed,Object? compatibilityMode = null,Object? disableStun = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self.unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,urlRewrites: null == urlRewrites ? _self.urlRewrites : urlRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,headerRewrites: null == headerRewrites ? _self.headerRewrites : headerRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,mapLocal: null == mapLocal ? _self.mapLocal : mapLocal // ignore: cast_nullable_to_non_nullable
as List<String>,bodyRewrites: null == bodyRewrites ? _self.bodyRewrites : bodyRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,mitmEnabled: null == mitmEnabled ? _self.mitmEnabled : mitmEnabled // ignore: cast_nullable_to_non_nullable
as bool,mitmHostnames: null == mitmHostnames ? _self.mitmHostnames : mitmHostnames // ignore: cast_nullable_to_non_nullable
as List<String>,proxyChains: null == proxyChains ? _self.proxyChains : proxyChains // ignore: cast_nullable_to_non_nullable
as Map<String, String>,generalSettings: null == generalSettings ? _self.generalSettings : generalSettings // ignore: cast_nullable_to_non_nullable
as GeneralSettings,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,frontProxyId: freezed == frontProxyId ? _self.frontProxyId : frontProxyId // ignore: cast_nullable_to_non_nullable
as String?,compatibilityMode: null == compatibilityMode ? _self.compatibilityMode : compatibilityMode // ignore: cast_nullable_to_non_nullable
as bool,disableStun: null == disableStun ? _self.disableStun : disableStun // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralSettingsCopyWith<$Res> get generalSettings {
  
  return $GeneralSettingsCopyWith<$Res>(_self.generalSettings, (value) {
    return _then(_self.copyWith(generalSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  Map<String, String> hosts,  List<String> urlRewrites,  List<String> headerRewrites,  List<String> mapLocal,  List<String> bodyRewrites,  bool mitmEnabled,  List<String> mitmHostnames,  Map<String, String> proxyChains,  GeneralSettings generalSettings,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order,  String? frontProxyId,  bool compatibilityMode,  bool disableStun)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.hosts,_that.urlRewrites,_that.headerRewrites,_that.mapLocal,_that.bodyRewrites,_that.mitmEnabled,_that.mitmHostnames,_that.proxyChains,_that.generalSettings,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order,_that.frontProxyId,_that.compatibilityMode,_that.disableStun);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  Map<String, String> hosts,  List<String> urlRewrites,  List<String> headerRewrites,  List<String> mapLocal,  List<String> bodyRewrites,  bool mitmEnabled,  List<String> mitmHostnames,  Map<String, String> proxyChains,  GeneralSettings generalSettings,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order,  String? frontProxyId,  bool compatibilityMode,  bool disableStun)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.hosts,_that.urlRewrites,_that.headerRewrites,_that.mapLocal,_that.bodyRewrites,_that.mitmEnabled,_that.mitmHostnames,_that.proxyChains,_that.generalSettings,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order,_that.frontProxyId,_that.compatibilityMode,_that.disableStun);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  Map<String, String> hosts,  List<String> urlRewrites,  List<String> headerRewrites,  List<String> mapLocal,  List<String> bodyRewrites,  bool mitmEnabled,  List<String> mitmHostnames,  Map<String, String> proxyChains,  GeneralSettings generalSettings,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order,  String? frontProxyId,  bool compatibilityMode,  bool disableStun)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.hosts,_that.urlRewrites,_that.headerRewrites,_that.mapLocal,_that.bodyRewrites,_that.mitmEnabled,_that.mitmHostnames,_that.proxyChains,_that.generalSettings,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order,_that.frontProxyId,_that.compatibilityMode,_that.disableStun);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.label = '', this.currentGroupName, this.url = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo, this.autoUpdate = true,  Map<String, String> selectedMap = const {},  Set<String> unfoldSet = const {},  Map<String, String> hosts = const {},  List<String> urlRewrites = const [],  List<String> headerRewrites = const [],  List<String> mapLocal = const [],  List<String> bodyRewrites = const [], this.mitmEnabled = false,  List<String> mitmHostnames = const [],  Map<String, String> proxyChains = const {}, this.generalSettings = const GeneralSettings(), this.overwriteType = OverwriteType.standard, this.scriptId, this.matchTarget, this.order, this.frontProxyId, this.compatibilityMode = false, this.disableStun = false}): _selectedMap = selectedMap,_unfoldSet = unfoldSet,_hosts = hosts,_urlRewrites = urlRewrites,_headerRewrites = headerRewrites,_mapLocal = mapLocal,_bodyRewrites = bodyRewrites,_mitmHostnames = mitmHostnames,_proxyChains = proxyChains;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  int id;
@override@JsonKey() final  String label;
@override final  String? currentGroupName;
@override@JsonKey() final  String url;
@override final  DateTime? lastUpdateDate;
@override final  Duration autoUpdateDuration;
@override final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey() final  bool autoUpdate;
 final  Map<String, String> _selectedMap;
@override@JsonKey() Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

 final  Set<String> _unfoldSet;
@override@JsonKey() Set<String> get unfoldSet {
  if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unfoldSet);
}

 final  Map<String, String> _hosts;
@override@JsonKey() Map<String, String> get hosts {
  if (_hosts is EqualUnmodifiableMapView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hosts);
}

 final  List<String> _urlRewrites;
@override@JsonKey() List<String> get urlRewrites {
  if (_urlRewrites is EqualUnmodifiableListView) return _urlRewrites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urlRewrites);
}

 final  List<String> _headerRewrites;
@override@JsonKey() List<String> get headerRewrites {
  if (_headerRewrites is EqualUnmodifiableListView) return _headerRewrites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headerRewrites);
}

 final  List<String> _mapLocal;
@override@JsonKey() List<String> get mapLocal {
  if (_mapLocal is EqualUnmodifiableListView) return _mapLocal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapLocal);
}

 final  List<String> _bodyRewrites;
@override@JsonKey() List<String> get bodyRewrites {
  if (_bodyRewrites is EqualUnmodifiableListView) return _bodyRewrites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bodyRewrites);
}

@override@JsonKey() final  bool mitmEnabled;
 final  List<String> _mitmHostnames;
@override@JsonKey() List<String> get mitmHostnames {
  if (_mitmHostnames is EqualUnmodifiableListView) return _mitmHostnames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mitmHostnames);
}

 final  Map<String, String> _proxyChains;
@override@JsonKey() Map<String, String> get proxyChains {
  if (_proxyChains is EqualUnmodifiableMapView) return _proxyChains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxyChains);
}

@override@JsonKey() final  GeneralSettings generalSettings;
@override@JsonKey() final  OverwriteType overwriteType;
@override final  int? scriptId;
@override final  String? matchTarget;
@override final  int? order;
@override final  String? frontProxyId;
@override@JsonKey() final  bool compatibilityMode;
@override@JsonKey() final  bool disableStun;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _unfoldSet)&&const DeepCollectionEquality().equals(other.hosts, _hosts)&&const DeepCollectionEquality().equals(other.urlRewrites, _urlRewrites)&&const DeepCollectionEquality().equals(other.headerRewrites, _headerRewrites)&&const DeepCollectionEquality().equals(other.mapLocal, _mapLocal)&&const DeepCollectionEquality().equals(other.bodyRewrites, _bodyRewrites)&&(identical(other.mitmEnabled, mitmEnabled) || other.mitmEnabled == mitmEnabled)&&const DeepCollectionEquality().equals(other.mitmHostnames, _mitmHostnames)&&const DeepCollectionEquality().equals(other.proxyChains, _proxyChains)&&(identical(other.generalSettings, generalSettings) || other.generalSettings == generalSettings)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId)&&(identical(other.matchTarget, matchTarget) || other.matchTarget == matchTarget)&&(identical(other.order, order) || other.order == order)&&(identical(other.frontProxyId, frontProxyId) || other.frontProxyId == frontProxyId)&&(identical(other.compatibilityMode, compatibilityMode) || other.compatibilityMode == compatibilityMode)&&(identical(other.disableStun, disableStun) || other.disableStun == disableStun));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),const DeepCollectionEquality().hash(_hosts),const DeepCollectionEquality().hash(_urlRewrites),const DeepCollectionEquality().hash(_headerRewrites),const DeepCollectionEquality().hash(_mapLocal),const DeepCollectionEquality().hash(_bodyRewrites),mitmEnabled,const DeepCollectionEquality().hash(_mitmHostnames),const DeepCollectionEquality().hash(_proxyChains),generalSettings,overwriteType,scriptId,matchTarget,order,frontProxyId,compatibilityMode,disableStun]);
}

@override
String toString() {
    return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, hosts: $hosts, urlRewrites: $urlRewrites, headerRewrites: $headerRewrites, mapLocal: $mapLocal, bodyRewrites: $bodyRewrites, mitmEnabled: $mitmEnabled, mitmHostnames: $mitmHostnames, proxyChains: $proxyChains, generalSettings: $generalSettings, overwriteType: $overwriteType, scriptId: $scriptId, matchTarget: $matchTarget, order: $order, frontProxyId: $frontProxyId, compatibilityMode: $compatibilityMode, disableStun: $disableStun)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, Map<String, String> hosts, List<String> urlRewrites, List<String> headerRewrites, List<String> mapLocal, List<String> bodyRewrites, bool mitmEnabled, List<String> mitmHostnames, Map<String, String> proxyChains, GeneralSettings generalSettings, OverwriteType overwriteType, int? scriptId, String? matchTarget, int? order, String? frontProxyId, bool compatibilityMode, bool disableStun
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;@override $GeneralSettingsCopyWith<$Res> get generalSettings;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? hosts = null,Object? urlRewrites = null,Object? headerRewrites = null,Object? mapLocal = null,Object? bodyRewrites = null,Object? mitmEnabled = null,Object? mitmHostnames = null,Object? proxyChains = null,Object? generalSettings = null,Object? overwriteType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,Object? frontProxyId = freezed,Object? compatibilityMode = null,Object? disableStun = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self._unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,urlRewrites: null == urlRewrites ? _self._urlRewrites : urlRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,headerRewrites: null == headerRewrites ? _self._headerRewrites : headerRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,mapLocal: null == mapLocal ? _self._mapLocal : mapLocal // ignore: cast_nullable_to_non_nullable
as List<String>,bodyRewrites: null == bodyRewrites ? _self._bodyRewrites : bodyRewrites // ignore: cast_nullable_to_non_nullable
as List<String>,mitmEnabled: null == mitmEnabled ? _self.mitmEnabled : mitmEnabled // ignore: cast_nullable_to_non_nullable
as bool,mitmHostnames: null == mitmHostnames ? _self._mitmHostnames : mitmHostnames // ignore: cast_nullable_to_non_nullable
as List<String>,proxyChains: null == proxyChains ? _self._proxyChains : proxyChains // ignore: cast_nullable_to_non_nullable
as Map<String, String>,generalSettings: null == generalSettings ? _self.generalSettings : generalSettings // ignore: cast_nullable_to_non_nullable
as GeneralSettings,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,frontProxyId: freezed == frontProxyId ? _self.frontProxyId : frontProxyId // ignore: cast_nullable_to_non_nullable
as String?,compatibilityMode: null == compatibilityMode ? _self.compatibilityMode : compatibilityMode // ignore: cast_nullable_to_non_nullable
as bool,disableStun: null == disableStun ? _self.disableStun : disableStun // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralSettingsCopyWith<$Res> get generalSettings {
  
  return $GeneralSettingsCopyWith<$Res>(_self.generalSettings, (value) {
    return _then(_self.copyWith(generalSettings: value));
  });
}
}

/// @nodoc
mixin _$ProfileRuleLink {

 int? get profileId; int get ruleId; RuleScene? get scene; String? get order;
/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileRuleLinkCopyWith<ProfileRuleLink> get copyWith => _$ProfileRuleLinkCopyWithImpl<ProfileRuleLink>(this as ProfileRuleLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileRuleLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileRuleLink&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.ruleId, _this.ruleId) || other.ruleId == _this.ruleId)&&(identical(other.scene, _this.scene) || other.scene == _this.scene)&&(identical(other.order, _this.order) || other.order == _this.order));
}


@override
int get hashCode {
  final _this = this as ProfileRuleLink;
  return Object.hash(runtimeType,_this.profileId,_this.ruleId,_this.scene,_this.order);
}

@override
String toString() {
  final _this = this as ProfileRuleLink;
  return 'ProfileRuleLink(profileId: ${_this.profileId}, ruleId: ${_this.ruleId}, scene: ${_this.scene}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $ProfileRuleLinkCopyWith<$Res>  {
  factory $ProfileRuleLinkCopyWith(ProfileRuleLink value, $Res Function(ProfileRuleLink) _then) = _$ProfileRuleLinkCopyWithImpl;
@useResult
$Res call({
 int? profileId, int ruleId, RuleScene? scene, String? order
});




}
/// @nodoc
class _$ProfileRuleLinkCopyWithImpl<$Res>
    implements $ProfileRuleLinkCopyWith<$Res> {
  _$ProfileRuleLinkCopyWithImpl(this._self, this._then);

  final ProfileRuleLink _self;
  final $Res Function(ProfileRuleLink) _then;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? ruleId = null,Object? scene = freezed,Object? order = freezed,}) {
  return _then(ProfileRuleLink(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,scene: freezed == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as RuleScene?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileRuleLink].
extension ProfileRuleLinkPatterns on ProfileRuleLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileRuleLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileRuleLink value)  $default,){
final _that = this;
switch (_that) {
case _ProfileRuleLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileRuleLink value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)  $default,) {final _that = this;
switch (_that) {
case _ProfileRuleLink():
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileRuleLink implements ProfileRuleLink {
  const _ProfileRuleLink({this.profileId, required this.ruleId, this.scene, this.order});
  

@override final  int? profileId;
@override final  int ruleId;
@override final  RuleScene? scene;
@override final  String? order;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileRuleLinkCopyWith<_ProfileRuleLink> get copyWith => __$ProfileRuleLinkCopyWithImpl<_ProfileRuleLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileRuleLink&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.scene, scene) || other.scene == scene)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,ruleId,scene,order);
}

@override
String toString() {
    return 'ProfileRuleLink(profileId: $profileId, ruleId: $ruleId, scene: $scene, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProfileRuleLinkCopyWith<$Res> implements $ProfileRuleLinkCopyWith<$Res> {
  factory _$ProfileRuleLinkCopyWith(_ProfileRuleLink value, $Res Function(_ProfileRuleLink) _then) = __$ProfileRuleLinkCopyWithImpl;
@override @useResult
$Res call({
 int? profileId, int ruleId, RuleScene? scene, String? order
});




}
/// @nodoc
class __$ProfileRuleLinkCopyWithImpl<$Res>
    implements _$ProfileRuleLinkCopyWith<$Res> {
  __$ProfileRuleLinkCopyWithImpl(this._self, this._then);

  final _ProfileRuleLink _self;
  final $Res Function(_ProfileRuleLink) _then;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? ruleId = null,Object? scene = freezed,Object? order = freezed,}) {
  return _then(_ProfileRuleLink(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,scene: freezed == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as RuleScene?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StandardOverwrite {

 List<Rule> get addedRules; List<int> get disabledRuleIds;
/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StandardOverwriteCopyWith<StandardOverwrite> get copyWith => _$StandardOverwriteCopyWithImpl<StandardOverwrite>(this as StandardOverwrite, _$identity);

  /// Serializes this StandardOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StandardOverwrite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StandardOverwrite&&const DeepCollectionEquality().equals(other.addedRules, _this.addedRules)&&const DeepCollectionEquality().equals(other.disabledRuleIds, _this.disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StandardOverwrite;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addedRules),const DeepCollectionEquality().hash(_this.disabledRuleIds));
}

@override
String toString() {
  final _this = this as StandardOverwrite;
  return 'StandardOverwrite(addedRules: ${_this.addedRules}, disabledRuleIds: ${_this.disabledRuleIds})';
}


}

/// @nodoc
abstract mixin class $StandardOverwriteCopyWith<$Res>  {
  factory $StandardOverwriteCopyWith(StandardOverwrite value, $Res Function(StandardOverwrite) _then) = _$StandardOverwriteCopyWithImpl;
@useResult
$Res call({
 List<Rule> addedRules, List<int> disabledRuleIds
});




}
/// @nodoc
class _$StandardOverwriteCopyWithImpl<$Res>
    implements $StandardOverwriteCopyWith<$Res> {
  _$StandardOverwriteCopyWithImpl(this._self, this._then);

  final StandardOverwrite _self;
  final $Res Function(StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(StandardOverwrite(
addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self.disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [StandardOverwrite].
extension StandardOverwritePatterns on StandardOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StandardOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StandardOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StandardOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<int> disabledRuleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<int> disabledRuleIds)  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite():
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Rule> addedRules,  List<int> disabledRuleIds)?  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StandardOverwrite implements StandardOverwrite {
  const _StandardOverwrite({ List<Rule> addedRules = const [],  List<int> disabledRuleIds = const []}): _addedRules = addedRules,_disabledRuleIds = disabledRuleIds;
  factory _StandardOverwrite.fromJson(Map<String, dynamic> json) => _$StandardOverwriteFromJson(json);

 final  List<Rule> _addedRules;
@override@JsonKey() List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

 final  List<int> _disabledRuleIds;
@override@JsonKey() List<int> get disabledRuleIds {
  if (_disabledRuleIds is EqualUnmodifiableListView) return _disabledRuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledRuleIds);
}


/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StandardOverwriteCopyWith<_StandardOverwrite> get copyWith => __$StandardOverwriteCopyWithImpl<_StandardOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StandardOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StandardOverwrite&&const DeepCollectionEquality().equals(other.addedRules, _addedRules)&&const DeepCollectionEquality().equals(other.disabledRuleIds, _disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addedRules),const DeepCollectionEquality().hash(_disabledRuleIds));
}

@override
String toString() {
    return 'StandardOverwrite(addedRules: $addedRules, disabledRuleIds: $disabledRuleIds)';
}


}

/// @nodoc
abstract mixin class _$StandardOverwriteCopyWith<$Res> implements $StandardOverwriteCopyWith<$Res> {
  factory _$StandardOverwriteCopyWith(_StandardOverwrite value, $Res Function(_StandardOverwrite) _then) = __$StandardOverwriteCopyWithImpl;
@override @useResult
$Res call({
 List<Rule> addedRules, List<int> disabledRuleIds
});




}
/// @nodoc
class __$StandardOverwriteCopyWithImpl<$Res>
    implements _$StandardOverwriteCopyWith<$Res> {
  __$StandardOverwriteCopyWithImpl(this._self, this._then);

  final _StandardOverwrite _self;
  final $Res Function(_StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(_StandardOverwrite(
addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self._disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$ScriptOverwrite {

 int? get scriptId;
/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptOverwriteCopyWith<ScriptOverwrite> get copyWith => _$ScriptOverwriteCopyWithImpl<ScriptOverwrite>(this as ScriptOverwrite, _$identity);

  /// Serializes this ScriptOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScriptOverwrite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptOverwrite&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScriptOverwrite;
  return Object.hash(runtimeType,_this.scriptId);
}

@override
String toString() {
  final _this = this as ScriptOverwrite;
  return 'ScriptOverwrite(scriptId: ${_this.scriptId})';
}


}

/// @nodoc
abstract mixin class $ScriptOverwriteCopyWith<$Res>  {
  factory $ScriptOverwriteCopyWith(ScriptOverwrite value, $Res Function(ScriptOverwrite) _then) = _$ScriptOverwriteCopyWithImpl;
@useResult
$Res call({
 int? scriptId
});




}
/// @nodoc
class _$ScriptOverwriteCopyWithImpl<$Res>
    implements $ScriptOverwriteCopyWith<$Res> {
  _$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final ScriptOverwrite _self;
  final $Res Function(ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scriptId = freezed,}) {
  return _then(ScriptOverwrite(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptOverwrite].
extension ScriptOverwritePatterns on ScriptOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? scriptId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? scriptId)  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite():
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? scriptId)?  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptOverwrite implements ScriptOverwrite {
  const _ScriptOverwrite({this.scriptId});
  factory _ScriptOverwrite.fromJson(Map<String, dynamic> json) => _$ScriptOverwriteFromJson(json);

@override final  int? scriptId;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptOverwriteCopyWith<_ScriptOverwrite> get copyWith => __$ScriptOverwriteCopyWithImpl<_ScriptOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptOverwrite&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,scriptId);
}

@override
String toString() {
    return 'ScriptOverwrite(scriptId: $scriptId)';
}


}

/// @nodoc
abstract mixin class _$ScriptOverwriteCopyWith<$Res> implements $ScriptOverwriteCopyWith<$Res> {
  factory _$ScriptOverwriteCopyWith(_ScriptOverwrite value, $Res Function(_ScriptOverwrite) _then) = __$ScriptOverwriteCopyWithImpl;
@override @useResult
$Res call({
 int? scriptId
});




}
/// @nodoc
class __$ScriptOverwriteCopyWithImpl<$Res>
    implements _$ScriptOverwriteCopyWith<$Res> {
  __$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final _ScriptOverwrite _self;
  final $Res Function(_ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scriptId = freezed,}) {
  return _then(_ScriptOverwrite(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
