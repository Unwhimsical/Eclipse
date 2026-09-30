// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

_GeneralSettings _$GeneralSettingsFromJson(Map<String, dynamic> json) =>
    _GeneralSettings(
      dnsServers:
          (json['dnsServers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fallbackDnsServers:
          (json['fallbackDnsServers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      directDnsServers:
          (json['directDnsServers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      skipProxy:
          (json['skipProxy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tunExcludedRoutes:
          (json['tunExcludedRoutes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tunIncludedRoutes:
          (json['tunIncludedRoutes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ipv6: json['ipv6'] as bool?,
      preferIpv6: json['preferIpv6'] as bool?,
      privateIpAnswer: json['privateIpAnswer'] as bool?,
      alwaysRealIp: json['alwaysRealIp'] as bool?,
      include: json['include'] as String?,
    );

Map<String, dynamic> _$GeneralSettingsToJson(_GeneralSettings instance) =>
    <String, dynamic>{
      'dnsServers': instance.dnsServers,
      'fallbackDnsServers': instance.fallbackDnsServers,
      'directDnsServers': instance.directDnsServers,
      'skipProxy': instance.skipProxy,
      'tunExcludedRoutes': instance.tunExcludedRoutes,
      'tunIncludedRoutes': instance.tunIncludedRoutes,
      'ipv6': instance.ipv6,
      'preferIpv6': instance.preferIpv6,
      'privateIpAnswer': instance.privateIpAnswer,
      'alwaysRealIp': instance.alwaysRealIp,
      'include': instance.include,
    };

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: (json['id'] as num).toInt(),
  label: json['label'] as String? ?? '',
  currentGroupName: json['currentGroupName'] as String?,
  url: json['url'] as String? ?? '',
  lastUpdateDate: json['lastUpdateDate'] == null
      ? null
      : DateTime.parse(json['lastUpdateDate'] as String),
  autoUpdateDuration: Duration(
    microseconds: (json['autoUpdateDuration'] as num).toInt(),
  ),
  subscriptionInfo: json['subscriptionInfo'] == null
      ? null
      : SubscriptionInfo.fromJson(
          json['subscriptionInfo'] as Map<String, dynamic>,
        ),
  autoUpdate: json['autoUpdate'] as bool? ?? true,
  selectedMap:
      (json['selectedMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  unfoldSet:
      (json['unfoldSet'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  hosts:
      (json['hosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  urlRewrites:
      (json['urlRewrites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  headerRewrites:
      (json['headerRewrites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mapLocal:
      (json['mapLocal'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bodyRewrites:
      (json['bodyRewrites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mitmEnabled: json['mitmEnabled'] as bool? ?? false,
  mitmHostnames:
      (json['mitmHostnames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  generalSettings: json['generalSettings'] == null
      ? const GeneralSettings()
      : GeneralSettings.fromJson(
          json['generalSettings'] as Map<String, dynamic>,
        ),
  overwriteType:
      $enumDecodeNullable(_$OverwriteTypeEnumMap, json['overwriteType']) ??
      OverwriteType.standard,
  scriptId: (json['scriptId'] as num?)?.toInt(),
  matchTarget: json['matchTarget'] as String?,
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'currentGroupName': instance.currentGroupName,
  'url': instance.url,
  'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
  'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
  'subscriptionInfo': instance.subscriptionInfo,
  'autoUpdate': instance.autoUpdate,
  'selectedMap': instance.selectedMap,
  'unfoldSet': instance.unfoldSet.toList(),
  'hosts': instance.hosts,
  'urlRewrites': instance.urlRewrites,
  'headerRewrites': instance.headerRewrites,
  'mapLocal': instance.mapLocal,
  'bodyRewrites': instance.bodyRewrites,
  'mitmEnabled': instance.mitmEnabled,
  'mitmHostnames': instance.mitmHostnames,
  'generalSettings': instance.generalSettings,
  'overwriteType': _$OverwriteTypeEnumMap[instance.overwriteType]!,
  'scriptId': instance.scriptId,
  'matchTarget': instance.matchTarget,
  'order': instance.order,
};

const _$OverwriteTypeEnumMap = {
  OverwriteType.standard: 'standard',
  OverwriteType.script: 'script',
  OverwriteType.custom: 'custom',
};

_StandardOverwrite _$StandardOverwriteFromJson(Map<String, dynamic> json) =>
    _StandardOverwrite(
      addedRules:
          (json['addedRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      disabledRuleIds:
          (json['disabledRuleIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StandardOverwriteToJson(_StandardOverwrite instance) =>
    <String, dynamic>{
      'addedRules': instance.addedRules,
      'disabledRuleIds': instance.disabledRuleIds,
    };

_ScriptOverwrite _$ScriptOverwriteFromJson(Map<String, dynamic> json) =>
    _ScriptOverwrite(scriptId: (json['scriptId'] as num?)?.toInt());

Map<String, dynamic> _$ScriptOverwriteToJson(_ScriptOverwrite instance) =>
    <String, dynamic>{'scriptId': instance.scriptId};
