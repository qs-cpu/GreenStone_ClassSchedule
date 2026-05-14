// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Timetable {

 String get id; String get userId; String get termId; String get title; String? get sourceId; DateTime get createdAt; DateTime get updatedAt; List<Course> get courses;
/// Create a copy of Timetable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableCopyWith<Timetable> get copyWith => _$TimetableCopyWithImpl<Timetable>(this as Timetable, _$identity);

  /// Serializes this Timetable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Timetable&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.termId, termId) || other.termId == termId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.courses, courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,termId,title,sourceId,createdAt,updatedAt,const DeepCollectionEquality().hash(courses));

@override
String toString() {
  return 'Timetable(id: $id, userId: $userId, termId: $termId, title: $title, sourceId: $sourceId, createdAt: $createdAt, updatedAt: $updatedAt, courses: $courses)';
}


}

/// @nodoc
abstract mixin class $TimetableCopyWith<$Res>  {
  factory $TimetableCopyWith(Timetable value, $Res Function(Timetable) _then) = _$TimetableCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String termId, String title, String? sourceId, DateTime createdAt, DateTime updatedAt, List<Course> courses
});




}
/// @nodoc
class _$TimetableCopyWithImpl<$Res>
    implements $TimetableCopyWith<$Res> {
  _$TimetableCopyWithImpl(this._self, this._then);

  final Timetable _self;
  final $Res Function(Timetable) _then;

/// Create a copy of Timetable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? termId = null,Object? title = null,Object? sourceId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? courses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,termId: null == termId ? _self.termId : termId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,courses: null == courses ? _self.courses : courses // ignore: cast_nullable_to_non_nullable
as List<Course>,
  ));
}

}


/// Adds pattern-matching-related methods to [Timetable].
extension TimetablePatterns on Timetable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Timetable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Timetable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Timetable value)  $default,){
final _that = this;
switch (_that) {
case _Timetable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Timetable value)?  $default,){
final _that = this;
switch (_that) {
case _Timetable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String termId,  String title,  String? sourceId,  DateTime createdAt,  DateTime updatedAt,  List<Course> courses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Timetable() when $default != null:
return $default(_that.id,_that.userId,_that.termId,_that.title,_that.sourceId,_that.createdAt,_that.updatedAt,_that.courses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String termId,  String title,  String? sourceId,  DateTime createdAt,  DateTime updatedAt,  List<Course> courses)  $default,) {final _that = this;
switch (_that) {
case _Timetable():
return $default(_that.id,_that.userId,_that.termId,_that.title,_that.sourceId,_that.createdAt,_that.updatedAt,_that.courses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String termId,  String title,  String? sourceId,  DateTime createdAt,  DateTime updatedAt,  List<Course> courses)?  $default,) {final _that = this;
switch (_that) {
case _Timetable() when $default != null:
return $default(_that.id,_that.userId,_that.termId,_that.title,_that.sourceId,_that.createdAt,_that.updatedAt,_that.courses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Timetable implements Timetable {
  const _Timetable({required this.id, required this.userId, required this.termId, required this.title, this.sourceId, required this.createdAt, required this.updatedAt, final  List<Course> courses = const []}): _courses = courses;
  factory _Timetable.fromJson(Map<String, dynamic> json) => _$TimetableFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String termId;
@override final  String title;
@override final  String? sourceId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<Course> _courses;
@override@JsonKey() List<Course> get courses {
  if (_courses is EqualUnmodifiableListView) return _courses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courses);
}


/// Create a copy of Timetable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimetableCopyWith<_Timetable> get copyWith => __$TimetableCopyWithImpl<_Timetable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimetableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Timetable&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.termId, termId) || other.termId == termId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._courses, _courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,termId,title,sourceId,createdAt,updatedAt,const DeepCollectionEquality().hash(_courses));

@override
String toString() {
  return 'Timetable(id: $id, userId: $userId, termId: $termId, title: $title, sourceId: $sourceId, createdAt: $createdAt, updatedAt: $updatedAt, courses: $courses)';
}


}

/// @nodoc
abstract mixin class _$TimetableCopyWith<$Res> implements $TimetableCopyWith<$Res> {
  factory _$TimetableCopyWith(_Timetable value, $Res Function(_Timetable) _then) = __$TimetableCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String termId, String title, String? sourceId, DateTime createdAt, DateTime updatedAt, List<Course> courses
});




}
/// @nodoc
class __$TimetableCopyWithImpl<$Res>
    implements _$TimetableCopyWith<$Res> {
  __$TimetableCopyWithImpl(this._self, this._then);

  final _Timetable _self;
  final $Res Function(_Timetable) _then;

/// Create a copy of Timetable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? termId = null,Object? title = null,Object? sourceId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? courses = null,}) {
  return _then(_Timetable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,termId: null == termId ? _self.termId : termId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,courses: null == courses ? _self._courses : courses // ignore: cast_nullable_to_non_nullable
as List<Course>,
  ));
}


}

// dart format on
