// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuoteModel _$QuoteModelFromJson(Map<String, dynamic> json) => _QuoteModel(
  id: json['_id'] as String,
  content: json['content'] as String,
  author: json['author'] as String,
);

Map<String, dynamic> _$QuoteModelToJson(_QuoteModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'content': instance.content,
      'author': instance.author,
    };
