import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Profile MITM fields', () {
    test('round-trips through JSON', () {
      final profile = Profile.normal(label: 'mitm').copyWith(
        mitmEnabled: true,
        mitmHostnames: const ['gs-loc.apple.com', 'example.com'],
      );

      final restored = Profile.fromJson(
        jsonDecode(jsonEncode(profile)) as Map<String, Object?>,
      );

      expect(restored, profile);
      expect(restored.mitmEnabled, isTrue);
      expect(restored.mitmHostnames, ['gs-loc.apple.com', 'example.com']);
    });

    test('defaults to disabled with no hostnames', () {
      final profile = Profile.normal();

      expect(profile.mitmEnabled, isFalse);
      expect(profile.mitmHostnames, isEmpty);
    });
  });

  group('Profile GeneralSettings', () {
    test('round-trips through JSON', () {
      final profile = Profile.normal(label: 'general').copyWith(
        generalSettings: const GeneralSettings(
          dnsServers: ['1.1.1.1'],
          fallbackDnsServers: ['8.8.8.8'],
          directDnsServers: ['223.5.5.5'],
          skipProxy: ['example.com'],
          tunExcludedRoutes: ['192.168.0.0/16'],
          tunIncludedRoutes: ['10.0.0.0/8'],
          ipv6: true,
          preferIpv6: true,
          privateIpAnswer: false,
          alwaysRealIp: true,
          include: 'https://example.com/remote.conf',
        ),
      );

      final restored = Profile.fromJson(
        jsonDecode(jsonEncode(profile)) as Map<String, Object?>,
      );

      expect(restored, profile);
      expect(restored.generalSettings.dnsServers, ['1.1.1.1']);
      expect(restored.generalSettings.fallbackDnsServers, ['8.8.8.8']);
      expect(restored.generalSettings.ipv6, isTrue);
      expect(restored.generalSettings.preferIpv6, isTrue);
      expect(restored.generalSettings.privateIpAnswer, isFalse);
      expect(restored.generalSettings.alwaysRealIp, isTrue);
      expect(
        restored.generalSettings.include,
        'https://example.com/remote.conf',
      );
    });

    test('defaults to empty lists with unset ipv6', () {
      final profile = Profile.normal();

      expect(profile.generalSettings.dnsServers, isEmpty);
      expect(profile.generalSettings.skipProxy, isEmpty);
      expect(profile.generalSettings.tunExcludedRoutes, isEmpty);
      expect(profile.generalSettings.ipv6, isNull);
      expect(profile.generalSettings.preferIpv6, isNull);
      expect(profile.generalSettings.privateIpAnswer, isNull);
      expect(profile.generalSettings.alwaysRealIp, isNull);
      expect(profile.generalSettings.include, isNull);
    });
  });

  group('SubscriptionInfo', () {
    test('parses subscription-userinfo header values', () {
      final info = SubscriptionInfo.formHString(
        'upload=10; download=20; total=100; expire=200',
      );

      expect(info.upload, 10);
      expect(info.download, 20);
      expect(info.total, 100);
      expect(info.expire, 200);
    });

    test('falls back to zero for null and invalid values', () {
      expect(SubscriptionInfo.formHString(null), const SubscriptionInfo());

      final info = SubscriptionInfo.formHString(
        'upload=bad; download=20; total=; expire=abc',
      );

      expect(info.upload, 0);
      expect(info.download, 20);
      expect(info.total, 0);
      expect(info.expire, 0);
    });
  });

  group('ProfileExtension', () {
    test('derives type, label, filename, and updating key', () {
      const fileProfile = Profile(
        id: 7,
        autoUpdateDuration: defaultUpdateDuration,
      );
      const urlProfile = Profile(
        id: 8,
        label: 'Remote',
        url: 'https://example.com/profile.yaml',
        autoUpdate: true,
        autoUpdateDuration: defaultUpdateDuration,
      );

      expect(fileProfile.type, ProfileType.file);
      expect(fileProfile.realAutoUpdate, false);
      expect(fileProfile.realLabel, '7');
      expect(fileProfile.fileName, '7.yaml');
      expect(fileProfile.updatingKey, 'profile_7');

      expect(urlProfile.type, ProfileType.url);
      expect(urlProfile.realAutoUpdate, true);
      expect(urlProfile.realLabel, 'Remote');
    });
  });

  group('ProfilesExt', () {
    test('gets profile by id', () {
      const profiles = [
        Profile(id: 1, label: 'A', autoUpdateDuration: defaultUpdateDuration),
        Profile(id: 2, label: 'B', autoUpdateDuration: defaultUpdateDuration),
      ];

      expect(profiles.getProfile(2)?.label, 'B');
      expect(profiles.getProfile(3), isNull);
      expect(profiles.getProfile(null), isNull);
    });

    test('optimizes duplicate labels with incremented suffix', () {
      const profiles = [
        Profile(
          id: 1,
          label: 'Work',
          autoUpdateDuration: defaultUpdateDuration,
        ),
        Profile(
          id: 2,
          label: 'Work(1)',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ];
      const newProfile = Profile(
        id: 3,
        label: 'Work',
        autoUpdateDuration: defaultUpdateDuration,
      );

      expect(profiles.optimizeLabel(newProfile).label, 'Work(2)');
    });
  });

  group('ProfileRuleLinkExt', () {
    test('builds stable key from non-null parts', () {
      const link = ProfileRuleLink(
        profileId: 1,
        ruleId: 2,
        scene: RuleScene.added,
      );
      const globalLink = ProfileRuleLink(ruleId: 3);

      expect(link.key, '1_2_added');
      expect(globalLink.key, '3');
    });
  });
}
