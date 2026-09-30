// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scene _$SceneFromJson(Map<String, dynamic> json) => _Scene(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  triggerType: $enumDecode(_$SceneTriggerTypeEnumMap, json['triggerType']),
  ssid: json['ssid'] as String?,
  targetProfileId: (json['targetProfileId'] as num?)?.toInt(),
  mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']),
  targetProxy: json['targetProxy'] as String?,
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SceneToJson(_Scene instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'triggerType': _$SceneTriggerTypeEnumMap[instance.triggerType]!,
  'ssid': instance.ssid,
  'targetProfileId': instance.targetProfileId,
  'mode': _$ModeEnumMap[instance.mode],
  'targetProxy': instance.targetProxy,
  'order': instance.order,
};

const _$SceneTriggerTypeEnumMap = {
  SceneTriggerType.ssid: 'ssid',
  SceneTriggerType.cellular: 'cellular',
  SceneTriggerType.fallback: 'fallback',
};

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};
