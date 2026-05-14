import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class Module with _$Module {
  const factory Module({
    required String id,
    required String title,
    required String duration,
    required int progress,
    String? classId,
    String? description,
    String? quizId,
    String? status,
    @Default(<String>[]) List<String> materials,
    @Default(false) bool isLocked,
  }) = _Module;

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
}
