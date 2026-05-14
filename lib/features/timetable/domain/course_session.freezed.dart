// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourseSession {

 String get id; String get courseId; int get weekday; int get startSection; int get endSection; int get startWeek; int get endWeek; String get weekType;// "all", "odd", "even"
 String? get location; String? get note; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CourseSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseSessionCopyWith<CourseSession> get copyWith => _$CourseSessionCopyWithImpl<CourseSession>(this as CourseSession, _$identity);

  /// Serializes this CourseSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourseSession&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startSection, startSection) || other.startSection == startSection)&&(identical(other.endSection, endSection) || other.endSection == endSection)&&(identical(other.startWeek, startWeek) || other.startWeek == startWeek)&&(identical(other.endWeek, endWeek) || other.endWeek == endWeek)&&(identical(other.weekType, weekType) || other.weekType == weekType)&&(identical(other.location, location) || other.location == location)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,weekday,startSection,endSection,startWeek,endWeek,weekType,location,note,createdAt,updatedAt);

@override
String toString() {
  return 'CourseSession(id: $id, courseId: $courseId, weekday: $weekday, startSection: $startSection, endSection: $endSection, startWeek: $startWeek, endWeek: $endWeek, weekType: $weekType, location: $location, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CourseSessionCopyWith<$Res>  {
  factory $CourseSessionCopyWith(CourseSession value, $Res Function(CourseSession) _then) = _$CourseSessionCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, int weekday, int startSection, int endSection, int startWeek, int endWeek, String weekType, String? location, String? note, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CourseSessionCopyWithImpl<$Res>
    implements $CourseSessionCopyWith<$Res> {
  _$CourseSessionCopyWithImpl(this._self, this._then);

  final CourseSession _self;
  final $Res Function(CourseSession) _then;

/// Create a copy of CourseSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? weekday = null,Object? startSection = null,Object? endSection = null,Object? startWeek = null,Object? endWeek = null,Object? weekType = null,Object? location = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startSection: null == startSection ? _self.startSection : startSection // ignore: cast_nullable_to_non_nullable
as int,endSection: null == endSection ? _self.endSection : endSection // ignore: cast_nullable_to_non_nullable
as int,startWeek: null == startWeek ? _self.startWeek : startWeek // ignore: cast_nullable_to_non_nullable
as int,endWeek: null == endWeek ? _self.endWeek : endWeek // ignore: cast_nullable_to_non_nullable
as int,weekType: null == weekType ? _self.weekType : weekType // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CourseSession].
extension CourseSessionPatterns on CourseSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourseSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourseSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourseSession value)  $default,){
final _that = this;
switch (_that) {
case _CourseSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourseSession value)?  $default,){
final _that = this;
switch (_that) {
case _CourseSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  int weekday,  int startSection,  int endSection,  int startWeek,  int endWeek,  String weekType,  String? location,  String? note,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourseSession() when $default != null:
return $default(_that.id,_that.courseId,_that.weekday,_that.startSection,_that.endSection,_that.startWeek,_that.endWeek,_that.weekType,_that.location,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  int weekday,  int startSection,  int endSection,  int startWeek,  int endWeek,  String weekType,  String? location,  String? note,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CourseSession():
return $default(_that.id,_that.courseId,_that.weekday,_that.startSection,_that.endSection,_that.startWeek,_that.endWeek,_that.weekType,_that.location,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  int weekday,  int startSection,  int endSection,  int startWeek,  int endWeek,  String weekType,  String? location,  String? note,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CourseSession() when $default != null:
return $default(_that.id,_that.courseId,_that.weekday,_that.startSection,_that.endSection,_that.startWeek,_that.endWeek,_that.weekType,_that.location,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourseSession implements CourseSession {
  const _CourseSession({required this.id, required this.courseId, required this.weekday, required this.startSection, required this.endSection, required this.startWeek, required this.endWeek, required this.weekType, this.location, this.note, required this.createdAt, required this.updatedAt});
  factory _CourseSession.fromJson(Map<String, dynamic> json) => _$CourseSessionFromJson(json);

@override final  String id;
@override final  String courseId;
@override final  int weekday;
@override final  int startSection;
@override final  int endSection;
@override final  int startWeek;
@override final  int endWeek;
@override final  String weekType;
// "all", "odd", "even"
@override final  String? location;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CourseSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseSessionCopyWith<_CourseSession> get copyWith => __$CourseSessionCopyWithImpl<_CourseSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourseSession&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startSection, startSection) || other.startSection == startSection)&&(identical(other.endSection, endSection) || other.endSection == endSection)&&(identical(other.startWeek, startWeek) || other.startWeek == startWeek)&&(identical(other.endWeek, endWeek) || other.endWeek == endWeek)&&(identical(other.weekType, weekType) || other.weekType == weekType)&&(identical(other.location, location) || other.location == location)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,weekday,startSection,endSection,startWeek,endWeek,weekType,location,note,createdAt,updatedAt);

@override
String toString() {
  return 'CourseSession(id: $id, courseId: $courseId, weekday: $weekday, startSection: $startSection, endSection: $endSection, startWeek: $startWeek, endWeek: $endWeek, weekType: $weekType, location: $location, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CourseSessionCopyWith<$Res> implements $CourseSessionCopyWith<$Res> {
  factory _$CourseSessionCopyWith(_CourseSession value, $Res Function(_CourseSession) _then) = __$CourseSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, int weekday, int startSection, int endSection, int startWeek, int endWeek, String weekType, String? location, String? note, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CourseSessionCopyWithImpl<$Res>
    implements _$CourseSessionCopyWith<$Res> {
  __$CourseSessionCopyWithImpl(this._self, this._then);

  final _CourseSession _self;
  final $Res Function(_CourseSession) _then;

/// Create a copy of CourseSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? weekday = null,Object? startSection = null,Object? endSection = null,Object? startWeek = null,Object? endWeek = null,Object? weekType = null,Object? location = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CourseSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startSection: null == startSection ? _self.startSection : startSection // ignore: cast_nullable_to_non_nullable
as int,endSection: null == endSection ? _self.endSection : endSection // ignore: cast_nullable_to_non_nullable
as int,startWeek: null == startWeek ? _self.startWeek : startWeek // ignore: cast_nullable_to_non_nullable
as int,endWeek: null == endWeek ? _self.endWeek : endWeek // ignore: cast_nullable_to_non_nullable
as int,weekType: null == weekType ? _self.weekType : weekType // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
