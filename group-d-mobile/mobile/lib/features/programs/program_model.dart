import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_model.freezed.dart';
part 'program_model.g.dart';

@freezed
class Program with _$Program {
  const factory Program({
    required String id,
    required String title,
    required String mentor,
    required int progress,
    @JsonKey(name: 'next_session') required DateTime nextSession,
    String? bannerUrl,
  }) = _Program;

  factory Program.fromJson(Map<String, dynamic> json) => _$ProgramFromJson(json);
}
