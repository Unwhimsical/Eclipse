import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/scene.freezed.dart';
part 'generated/scene.g.dart';

@freezed
abstract class Scene with _$Scene {
  const factory Scene({
    required int id,
    required String name,
    required SceneTriggerType triggerType,
    String? ssid,
    int? targetProfileId,
    Mode? mode,
    String? targetProxy,
    @Default(0) int order,
  }) = _Scene;

  factory Scene.fromJson(Map<String, Object?> json) => _$SceneFromJson(json);
}
