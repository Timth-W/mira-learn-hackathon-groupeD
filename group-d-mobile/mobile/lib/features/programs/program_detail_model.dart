import 'package:freezed_annotation/freezed_annotation.dart';
import '../modules/module_model.dart';

part 'program_detail_model.freezed.dart';
part 'program_detail_model.g.dart';

@freezed
class ProgramDetail with _$ProgramDetail {
  const factory ProgramDetail({
    required String id,
    required String title,
    required String description,
    required int globalProgress,
    required List<Module> modules,
  }) = _ProgramDetail;

  factory ProgramDetail.fromJson(Map<String, dynamic> json) => _$ProgramDetailFromJson(json);
}
