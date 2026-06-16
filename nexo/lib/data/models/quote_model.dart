import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

// model da citação - vem da api zenquotes.io
// resposta da api: [{"q": "...", "a": "...", "h": "..."}]
@freezed
abstract class QuoteModel with _$QuoteModel {
  // ignore: invalid_annotation_target
  const factory QuoteModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'q') required String content,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'a') required String author,
  }) = _QuoteModel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);
}