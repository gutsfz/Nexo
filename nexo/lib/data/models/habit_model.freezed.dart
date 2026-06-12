// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HabitModel {

 int get id; String get name; String get emoji; String get category;// weekdays salvo como string "0,1,3" - índices dos dias da semana
 String get weekdays; String get createdAt;
/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitModelCopyWith<HabitModel> get copyWith => _$HabitModelCopyWithImpl<HabitModel>(this as HabitModel, _$identity);

  /// Serializes this HabitModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.weekdays, weekdays) || other.weekdays == weekdays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,category,weekdays,createdAt);

@override
String toString() {
  return 'HabitModel(id: $id, name: $name, emoji: $emoji, category: $category, weekdays: $weekdays, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $HabitModelCopyWith<$Res>  {
  factory $HabitModelCopyWith(HabitModel value, $Res Function(HabitModel) _then) = _$HabitModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String emoji, String category, String weekdays, String createdAt
});




}
/// @nodoc
class _$HabitModelCopyWithImpl<$Res>
    implements $HabitModelCopyWith<$Res> {
  _$HabitModelCopyWithImpl(this._self, this._then);

  final HabitModel _self;
  final $Res Function(HabitModel) _then;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? category = null,Object? weekdays = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitModel].
extension HabitModelPatterns on HabitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitModel value)  $default,){
final _that = this;
switch (_that) {
case _HabitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitModel value)?  $default,){
final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String emoji,  String category,  String weekdays,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.weekdays,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String emoji,  String category,  String weekdays,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _HabitModel():
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.weekdays,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String emoji,  String category,  String weekdays,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.weekdays,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HabitModel implements HabitModel {
  const _HabitModel({required this.id, required this.name, required this.emoji, required this.category, required this.weekdays, required this.createdAt});
  factory _HabitModel.fromJson(Map<String, dynamic> json) => _$HabitModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String emoji;
@override final  String category;
// weekdays salvo como string "0,1,3" - índices dos dias da semana
@override final  String weekdays;
@override final  String createdAt;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitModelCopyWith<_HabitModel> get copyWith => __$HabitModelCopyWithImpl<_HabitModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.weekdays, weekdays) || other.weekdays == weekdays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,category,weekdays,createdAt);

@override
String toString() {
  return 'HabitModel(id: $id, name: $name, emoji: $emoji, category: $category, weekdays: $weekdays, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$HabitModelCopyWith<$Res> implements $HabitModelCopyWith<$Res> {
  factory _$HabitModelCopyWith(_HabitModel value, $Res Function(_HabitModel) _then) = __$HabitModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String emoji, String category, String weekdays, String createdAt
});




}
/// @nodoc
class __$HabitModelCopyWithImpl<$Res>
    implements _$HabitModelCopyWith<$Res> {
  __$HabitModelCopyWithImpl(this._self, this._then);

  final _HabitModel _self;
  final $Res Function(_HabitModel) _then;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? category = null,Object? weekdays = null,Object? createdAt = null,}) {
  return _then(_HabitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
