// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HabitModel _$HabitModelFromJson(Map<String, dynamic> json) => _HabitModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  emoji: json['emoji'] as String,
  category: json['category'] as String,
  weekdays: json['weekdays'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$HabitModelToJson(_HabitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emoji': instance.emoji,
      'category': instance.category,
      'weekdays': instance.weekdays,
      'createdAt': instance.createdAt,
    };
