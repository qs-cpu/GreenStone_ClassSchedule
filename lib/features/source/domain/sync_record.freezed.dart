// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncRecord {

 String get id; String get sourceId; String get status; String? get message; DateTime get startedAt; DateTime? get finishedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncRecordCopyWith<SyncRecord> get copyWith => _$SyncRecordCopyWithImpl<SyncRecord>(this as SyncRecord, _$identity);

  /// Serializes this SyncRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,status,message,startedAt,finishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SyncRecord(id: $id, sourceId: $sourceId, status: $status, message: $message, startedAt: $startedAt, finishedAt: $finishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SyncRecordCopyWith<$Res>  {
  factory $SyncRecordCopyWith(SyncRecord value, $Res Function(SyncRecord) _then) = _$SyncRecordCopyWithImpl;
@useResult
$Res call({
 String id, String sourceId, String status, String? message, DateTime startedAt, DateTime? finishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SyncRecordCopyWithImpl<$Res>
    implements $SyncRecordCopyWith<$Res> {
  _$SyncRecordCopyWithImpl(this._self, this._then);

  final SyncRecord _self;
  final $Res Function(SyncRecord) _then;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceId = null,Object? status = null,Object? message = freezed,Object? startedAt = null,Object? finishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncRecord].
extension SyncRecordPatterns on SyncRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncRecord value)  $default,){
final _that = this;
switch (_that) {
case _SyncRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sourceId,  String status,  String? message,  DateTime startedAt,  DateTime? finishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
return $default(_that.id,_that.sourceId,_that.status,_that.message,_that.startedAt,_that.finishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sourceId,  String status,  String? message,  DateTime startedAt,  DateTime? finishedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SyncRecord():
return $default(_that.id,_that.sourceId,_that.status,_that.message,_that.startedAt,_that.finishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sourceId,  String status,  String? message,  DateTime startedAt,  DateTime? finishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
return $default(_that.id,_that.sourceId,_that.status,_that.message,_that.startedAt,_that.finishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncRecord implements SyncRecord {
  const _SyncRecord({required this.id, required this.sourceId, required this.status, this.message, required this.startedAt, this.finishedAt, required this.createdAt, required this.updatedAt});
  factory _SyncRecord.fromJson(Map<String, dynamic> json) => _$SyncRecordFromJson(json);

@override final  String id;
@override final  String sourceId;
@override final  String status;
@override final  String? message;
@override final  DateTime startedAt;
@override final  DateTime? finishedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncRecordCopyWith<_SyncRecord> get copyWith => __$SyncRecordCopyWithImpl<_SyncRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,status,message,startedAt,finishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SyncRecord(id: $id, sourceId: $sourceId, status: $status, message: $message, startedAt: $startedAt, finishedAt: $finishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SyncRecordCopyWith<$Res> implements $SyncRecordCopyWith<$Res> {
  factory _$SyncRecordCopyWith(_SyncRecord value, $Res Function(_SyncRecord) _then) = __$SyncRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String sourceId, String status, String? message, DateTime startedAt, DateTime? finishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SyncRecordCopyWithImpl<$Res>
    implements _$SyncRecordCopyWith<$Res> {
  __$SyncRecordCopyWithImpl(this._self, this._then);

  final _SyncRecord _self;
  final $Res Function(_SyncRecord) _then;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceId = null,Object? status = null,Object? message = freezed,Object? startedAt = null,Object? finishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SyncRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
