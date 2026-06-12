// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompletionModel _$CompletionModelFromJson(Map<String, dynamic> json) =>
    _CompletionModel(
      id: (json['id'] as num).toInt(),
      habitId: (json['habitId'] as num).toInt(),
      completedAt: json['completedAt'] as String,
    );

Map<String, dynamic> _$CompletionModelToJson(_CompletionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'habitId': instance.habitId,
      'completedAt': instance.completedAt,
    };
