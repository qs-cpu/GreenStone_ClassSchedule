// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimetableSource {

 String get id; String get userId; String get originalUrl; String? get finalUrl; String get sourceType;// "ICS", "JSON", "HTML", "UNKNOWN"
 String? get importerKey; String? get etag; DateTime? get lastModified; DateTime? get lastSyncedAt; String get syncStatus;// "idle", "syncing", "success", "failed"
 String? get errorMessage; DateTime get createdAt; DateTime get updatedAt; List<SyncRecord> get syncRecords;
/// Create a copy of TimetableSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableSourceCopyWith<TimetableSource> get copyWith => _$TimetableSourceCopyWithImpl<TimetableSource>(this as TimetableSource, _$identity);

  /// Serializes this TimetableSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableSource&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.originalUrl, originalUrl) || other.originalUrl == originalUrl)&&(identical(other.finalUrl, finalUrl) || other.finalUrl == finalUrl)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.importerKey, importerKey) || other.importerKey == importerKey)&&(identical(other.etag, etag) || other.etag == etag)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.syncRecords, syncRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,originalUrl,finalUrl,sourceType,importerKey,etag,lastModified,lastSyncedAt,syncStatus,errorMessage,createdAt,updatedAt,const DeepCollectionEquality().hash(syncRecords));

@override
String toString() {
  return 'TimetableSource(id: $id, userId: $userId, originalUrl: $originalUrl, finalUrl: $finalUrl, sourceType: $sourceType, importerKey: $importerKey, etag: $etag, lastModified: $lastModified, lastSyncedAt: $lastSyncedAt, syncStatus: $syncStatus, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt, syncRecords: $syncRecords)';
}


}

/// @nodoc
abstract mixin class $TimetableSourceCopyWith<$Res>  {
  factory $TimetableSourceCopyWith(TimetableSource value, $Res Function(TimetableSource) _then) = _$TimetableSourceCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String originalUrl, String? finalUrl, String sourceType, String? importerKey, String? etag, DateTime? lastModified, DateTime? lastSyncedAt, String syncStatus, String? errorMessage, DateTime createdAt, DateTime updatedAt, List<SyncRecord> syncRecords
});




}
/// @nodoc
class _$TimetableSourceCopyWithImpl<$Res>
    implements $TimetableSourceCopyWith<$Res> {
  _$TimetableSourceCopyWithImpl(this._self, this._then);

  final TimetableSource _self;
  final $Res Function(TimetableSource) _then;

/// Create a copy of TimetableSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? originalUrl = null,Object? finalUrl = freezed,Object? sourceType = null,Object? importerKey = freezed,Object? etag = freezed,Object? lastModified = freezed,Object? lastSyncedAt = freezed,Object? syncStatus = null,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,Object? syncRecords = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,originalUrl: null == originalUrl ? _self.originalUrl : originalUrl // ignore: cast_nullable_to_non_nullable
as String,finalUrl: freezed == finalUrl ? _self.finalUrl : finalUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,importerKey: freezed == importerKey ? _self.importerKey : importerKey // ignore: cast_nullable_to_non_nullable
as String?,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncRecords: null == syncRecords ? _self.syncRecords : syncRecords // ignore: cast_nullable_to_non_nullable
as List<SyncRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimetableSource].
extension TimetableSourcePatterns on TimetableSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimetableSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimetableSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimetableSource value)  $default,){
final _that = this;
switch (_that) {
case _TimetableSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimetableSource value)?  $default,){
final _that = this;
switch (_that) {
case _TimetableSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String originalUrl,  String? finalUrl,  String sourceType,  String? importerKey,  String? etag,  DateTime? lastModified,  DateTime? lastSyncedAt,  String syncStatus,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt,  List<SyncRecord> syncRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimetableSource() when $default != null:
return $default(_that.id,_that.userId,_that.originalUrl,_that.finalUrl,_that.sourceType,_that.importerKey,_that.etag,_that.lastModified,_that.lastSyncedAt,_that.syncStatus,_that.errorMessage,_that.createdAt,_that.updatedAt,_that.syncRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String originalUrl,  String? finalUrl,  String sourceType,  String? importerKey,  String? etag,  DateTime? lastModified,  DateTime? lastSyncedAt,  String syncStatus,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt,  List<SyncRecord> syncRecords)  $default,) {final _that = this;
switch (_that) {
case _TimetableSource():
return $default(_that.id,_that.userId,_that.originalUrl,_that.finalUrl,_that.sourceType,_that.importerKey,_that.etag,_that.lastModified,_that.lastSyncedAt,_that.syncStatus,_that.errorMessage,_that.createdAt,_that.updatedAt,_that.syncRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String originalUrl,  String? finalUrl,  String sourceType,  String? importerKey,  String? etag,  DateTime? lastModified,  DateTime? lastSyncedAt,  String syncStatus,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt,  List<SyncRecord> syncRecords)?  $default,) {final _that = this;
switch (_that) {
case _TimetableSource() when $default != null:
return $default(_that.id,_that.userId,_that.originalUrl,_that.finalUrl,_that.sourceType,_that.importerKey,_that.etag,_that.lastModified,_that.lastSyncedAt,_that.syncStatus,_that.errorMessage,_that.createdAt,_that.updatedAt,_that.syncRecords);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimetableSource implements TimetableSource {
  const _TimetableSource({required this.id, required this.userId, required this.originalUrl, this.finalUrl, required this.sourceType, this.importerKey, this.etag, this.lastModified, this.lastSyncedAt, required this.syncStatus, this.errorMessage, required this.createdAt, required this.updatedAt, final  List<SyncRecord> syncRecords = const []}): _syncRecords = syncRecords;
  factory _TimetableSource.fromJson(Map<String, dynamic> json) => _$TimetableSourceFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String originalUrl;
@override final  String? finalUrl;
@override final  String sourceType;
// "ICS", "JSON", "HTML", "UNKNOWN"
@override final  String? importerKey;
@override final  String? etag;
@override final  DateTime? lastModified;
@override final  DateTime? lastSyncedAt;
@override final  String syncStatus;
// "idle", "syncing", "success", "failed"
@override final  String? errorMessage;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<SyncRecord> _syncRecords;
@override@JsonKey() List<SyncRecord> get syncRecords {
  if (_syncRecords is EqualUnmodifiableListView) return _syncRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_syncRecords);
}


/// Create a copy of TimetableSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimetableSourceCopyWith<_TimetableSource> get copyWith => __$TimetableSourceCopyWithImpl<_TimetableSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimetableSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimetableSource&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.originalUrl, originalUrl) || other.originalUrl == originalUrl)&&(identical(other.finalUrl, finalUrl) || other.finalUrl == finalUrl)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.importerKey, importerKey) || other.importerKey == importerKey)&&(identical(other.etag, etag) || other.etag == etag)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._syncRecords, _syncRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,originalUrl,finalUrl,sourceType,importerKey,etag,lastModified,lastSyncedAt,syncStatus,errorMessage,createdAt,updatedAt,const DeepCollectionEquality().hash(_syncRecords));

@override
String toString() {
  return 'TimetableSource(id: $id, userId: $userId, originalUrl: $originalUrl, finalUrl: $finalUrl, sourceType: $sourceType, importerKey: $importerKey, etag: $etag, lastModified: $lastModified, lastSyncedAt: $lastSyncedAt, syncStatus: $syncStatus, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt, syncRecords: $syncRecords)';
}


}

/// @nodoc
abstract mixin class _$TimetableSourceCopyWith<$Res> implements $TimetableSourceCopyWith<$Res> {
  factory _$TimetableSourceCopyWith(_TimetableSource value, $Res Function(_TimetableSource) _then) = __$TimetableSourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String originalUrl, String? finalUrl, String sourceType, String? importerKey, String? etag, DateTime? lastModified, DateTime? lastSyncedAt, String syncStatus, String? errorMessage, DateTime createdAt, DateTime updatedAt, List<SyncRecord> syncRecords
});




}
/// @nodoc
class __$TimetableSourceCopyWithImpl<$Res>
    implements _$TimetableSourceCopyWith<$Res> {
  __$TimetableSourceCopyWithImpl(this._self, this._then);

  final _TimetableSource _self;
  final $Res Function(_TimetableSource) _then;

/// Create a copy of TimetableSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? originalUrl = null,Object? finalUrl = freezed,Object? sourceType = null,Object? importerKey = freezed,Object? etag = freezed,Object? lastModified = freezed,Object? lastSyncedAt = freezed,Object? syncStatus = null,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,Object? syncRecords = null,}) {
  return _then(_TimetableSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,originalUrl: null == originalUrl ? _self.originalUrl : originalUrl // ignore: cast_nullable_to_non_nullable
as String,finalUrl: freezed == finalUrl ? _self.finalUrl : finalUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,importerKey: freezed == importerKey ? _self.importerKey : importerKey // ignore: cast_nullable_to_non_nullable
as String?,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncRecords: null == syncRecords ? _self._syncRecords : syncRecords // ignore: cast_nullable_to_non_nullable
as List<SyncRecord>,
  ));
}


}

// dart format on
